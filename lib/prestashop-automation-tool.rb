require 'uri'
require 'apache-vhosts-parser'
require 'prestashop-automation'

module PrestaShopAutomationTool
	class ConfigurationParser

		attr_reader :config

		def initialize root
			@root = File.realpath(root)

			vhosts = ApacheVhostsParser.parseDirectory

			if url = vhosts.urlFor(@root)
				fou = "http://#{url}/"
			else
				fou = "http://localhost/#{File.basename(@root)}/"
			end

			@config_fields = {
				database_user: '',
				database_password: '',
				database_name: '',
				database_prefix: 'ps_',
				database_host: 'localhost',
				version: '',
				front_office_url: fou,
				back_office_url: nil,
				installer_url: nil,
				admin_email: 'pub@prestashop.com',
				admin_password: '123456789',
				default_customer_email: 'pub@prestashop.com',
				default_customer_password: '123456789'
			}

			@config = {}
		end
		def parse
			if File.exists? path=File.join(@root, 'config', 'settings.inc.php')
				config = Hash[File.read(path).scan(/\bdefine\s*\(\s*'(.*?)'\s*,\s*'(.*?)'\s*\)\s*;/)]

				mapping = {
					database_user: '_DB_USER_',
					database_password: '_DB_PASSWD_',
					database_name: '_DB_NAME_',
					database_prefix: '_DB_PREFIX_',
					database_host: '_DB_SERVER_',
					version: '_PS_VERSION_'
				}

				@config_fields.each_pair do |key, default_value|
					if (value = config[mapping[key]].to_s.strip) != ''
						@config[key] = value
					end
				end
			end

			Dir.entries('.').each do |entry|
				unless entry =~ /^\./
					if File.directory? entry
						if File.exists? File.join(entry, 'ajax-tab.php')
							@admin_folder = entry
						elsif File.exists? File.join(entry, 'index_cli.php')
							@installer_folder = entry
						end
					end
				end
			end
		end
		def ask_user_for_missing_info options={}
			@config_fields.each_pair do |key, default_value|
				unless @config[key]
					if default_value
						default = default_value != '' ? " (default: \"#{default_value.to_s})\"" : ''
						unless options[:accept_defaults]
							print "#{key.to_s.split('_').map(&:capitalize).join ' '}#{default}? "
							value = $stdin.gets.strip
							value = default_value if value == ""
							@config[key] = value
						else
							@config[key] = default_value
						end
					end
				end
			end
		end

		def autocomplete_config
			if m = @config[:database_host].match(/^(.*?)\:(.*?)$/)
				@config[:database_host] = m[1]
				@config[:database_port] = m[2]
			end

			if @admin_folder
				@config[:back_office_url] = URI.join(@config[:front_office_url], @admin_folder, '/').to_s
			end
			if @installer_folder
				@config[:installer_url] = URI.join(@config[:front_office_url], @installer_folder, '/').to_s
			end
		end
	end
end
