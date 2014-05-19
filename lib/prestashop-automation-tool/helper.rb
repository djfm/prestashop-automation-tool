require 'prestashop-automation'
require 'json'

dump = nil

RSpec.configure do |config|
	config.before :all do
		conf = JSON.parse(File.read('pat.conf.json'), :symbolize_names => true)
		@shop = PrestaShopAutomation::PrestaShop.new conf[:shop]
		unless ENV['NO_RESTORE'] == '1'
			dump = @shop.save
		end
	end

	config.after :all do
		unless ENV['NO_RESTORE'] == '1'
			@shop.restore dump
		end
	end
end
