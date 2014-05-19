#!/usr/bin/ruby
require 'prestashop-automation-tool'

require 'optparse'
require 'json'

def withConfig &block
	if File.exists? 'pat.conf.json'
		yield JSON.parse(File.read('pat.conf.json'), :symbolize_names => true)
	else
		abort "Could not find the config file #{pat.conf.json}, did you run 'pat.rb init'?"
	end
end

options = {}
OptionParser.new do |opts|
	opts.on('-ad', '--accept-defaults', 'Accept default values automatically.') do
		options[:accept_defaults] = true
	end
	opts.on('--no-restore', 'Do not save/restore intial state when running tests.') do
		options[:no_restore] = true
	end
end.parse!
if ARGV.count == 0
	puts "Missing action argument!"
	exit 1
elsif ARGV[0] == 'init'
	conf = PrestaShopAutomationTool::ConfigurationParser.new '.'
	conf.parse
	conf.ask_user_for_missing_info options
	conf.autocomplete_config
	File.write 'pat.conf.json', JSON.pretty_generate({
		shop: conf.config
	})
	unless File.exists? 'pat-tests'
		Dir.mkdir 'pat-tests'
	end
elsif ARGV[0] == 'install'
	withConfig do |conf|
		ps = PrestaShopAutomation::PrestaShop.new(conf[:shop])
		ps.drop_database
		ps.install options
	end
elsif ARGV[0] == 'dump'
	withConfig do |conf|
		ps = PrestaShopAutomation::PrestaShop.new(conf[:shop])
		ps.dump_database 'dump.sql'
	end
elsif ARGV[0] == 'restore'
	withConfig do |conf|
		ps = PrestaShopAutomation::PrestaShop.new(conf[:shop])
		ps.load_database 'dump.sql'
	end
elsif ARGV[0] == 'test'

	list = ARGV[1..-1]

	if list.nil? or list.empty?
		list = Dir.glob('pat-tests/**/*')
	end

	list.sort!

	list.each do |file|
		ok = if file =~ /\.rb$/
			puts "Running #{file}..."
			system({'NO_RESTORE' => options[:no_restore]}, 'rspec', file)
		elsif file =~ /\.json$/
			puts "Running #{file}..."
			data = JSON.parse File.read(file)
			runner = "pat-runner-#{data['spec']['runner']}.rb"
			system({'PAT_SOURCE' => file, 'NO_RESTORE' => (options[:no_restore] ? '1' : '0')}, runner)
		else
			:not_runnable
		end

		if ok != :not_runnable
			puts "Ran #{file}: #{ok ? "success!" : "FAILED"}"
		end

	end
end
