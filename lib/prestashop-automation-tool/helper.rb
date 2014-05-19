require 'prestashop-automation'
require 'json'

dump = nil

RSpec.configure do |config|
	config.before :all do
		conf = JSON.parse(File.read('pat.conf.json'), :symbolize_names => true)
		@shop = PrestaShopAutomation::PrestaShop.new conf[:shop]
		dump = @shop.save
	end

	config.after :all do
		@shop.restore dump
	end
end
