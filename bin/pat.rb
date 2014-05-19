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
	opts.on('-ad', '--accept-defaults', 'Accept default values automatically') do
		options[:accept_defaults] = true
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
elsif ARGV[0] == 'run'

	list = ARGV[1..-1]

	if list.nil? or list.empty?
		list = Dir.glob('pat-tests/**/*')
	end

	list.each do |file|
		if file =~ /\.rb$/
			exec 'rspec', file
		elsif file =~ /\.json$/
			data = JSON.parse File.read(file)
			runner = "pat-runner-#{data['spec']['runner']}.rb"
			exec({'PAT_SOURCE' => file}, runner)
		end
	end
end
