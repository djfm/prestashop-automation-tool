#!/usr/bin/ruby
require_relative '../lib/prestashop-automation-tool.rb'

require 'optparse'
require 'json'

options = {}
OptionParser.new do |opts|
	opts.on('-ad', '--accept-defaults', 'Accept default values automatically') do
		options[:accept_defaults] = true
	end
end.parse!

if ARGV.count != 1
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
end
