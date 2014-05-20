require 'prestashop-automation-tool/helper'

describe 'My first test' do
	it 'should login as a customer' do
		@shop.login_to_front_office
	end
end
