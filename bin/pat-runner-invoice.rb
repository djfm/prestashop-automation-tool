#!/usr/bin/ruby

require 'rspec'
require 'rspec/autorun'
require 'prestashop-automation-tool/helper'

def test_invoice ps, scenario, options={}

	taxes = {}
	groups = {}

	ps.login_to_back_office
	ps.set_friendly_urls false
	ps.set_order_process_type scenario['meta']['order_process'].to_sym

	if scenario["discounts"]
		scenario["discounts"].each_pair do |name, amount|
			ps.create_cart_rule :name=> name, :amount => amount
		end
	end

	if scenario["gift_wrapping"]
		ps.set_gift_wrapping_option true,
			:price => scenario["gift_wrapping"]["price"],
			:tax_group_id => scenario["gift_wrapping"]["vat"] ? ps.create_tax_group_from_rate(scenario["gift_wrapping"]["vat"], taxes, groups) : nil,
			:recycling_option => false
	else
		ps.set_gift_wrapping_option false
	end

	ps.set_rounding_rule scenario['meta']['rounding_rule']
	ps.set_rounding_method scenario['meta']['rounding_method']

	if scenario['meta']['ecotax']
		ps.set_ecotax_option true, ps.create_tax_group_from_rate(scenario['meta']['ecotax'], taxes, groups)
	else
		ps.set_ecotax_option false
	end

	carrier_name = ps.create_carrier({
		:name => scenario['carrier']['name'],
		:with_handling_fees => scenario['carrier']['with_handling_fees'],
		:free_shipping => scenario['carrier']['shipping_fees'] == 0,
		:ranges => [{:from_included => 0, :to_excluded => 1000, :prices => {0 => scenario['carrier']['shipping_fees']}}],
		:tax_group_id => scenario['carrier']['vat'] ? ps.create_tax_group_from_rate(scenario['carrier']['vat'], taxes, groups) : nil
	})

	products = []
	scenario['products'].each_pair do |name, data|
		id = ps.create_product({
			:name => name,
			:price => data['price'],
			:tax_group_id => ps.create_tax_group_from_rate(data['vat'], taxes, groups),
			:ecotax => data['ecotax'],
			:specific_price => data['specific_price']
		})
		products << {id: id, quantity: data['quantity']}

		if data["discount"]
			ps.create_cart_rule({
				:product_id => id,
				:amount => data["discount"],
				:free_shipping => false,
				:name => "#{name} with (#{data['discount']}) discount"
			})
		end
	end

	ps.login_to_front_office
	ps.add_products_to_cart products

	order_id = if scenario['meta']['order_process'] == 'five_steps'
		ps.order_current_cart_5_steps :carrier => carrier_name, :gift_wrapping => scenario["gift_wrapping"]
	else
		ps.order_current_cart_opc :carrier => carrier_name, :gift_wrapping => scenario["gift_wrapping"]
	end

	ps.goto_back_office
	invoice = ps.validate_order :id => order_id, :dump_pdf_to => options[:dump_pdf_to], :get_invoice_json => true

	if scenario['expect']['invoice']
		if expected_total = scenario['expect']['invoice']['total']
			actual_total = invoice['order']
			mapping = {
				'to_pay_tax_included' => 'total_paid_tax_incl',
				'to_pay_tax_excluded' => 'total_paid_tax_excl',
				'products_tax_included' => 'total_products_wt',
				'products_tax_excluded' => 'total_products',
				'shipping_tax_included' => 'total_shipping_tax_incl',
				'shipping_tax_excluded' => 'total_shipping_tax_excl',
				'discounts_tax_included' => 'total_discounts_tax_incl',
				'discounts_tax_excluded' => 'total_discounts_tax_excl',
				'wrapping_tax_included' => 'total_wrapping_tax_incl',
				'wrapping_tax_excluded' => 'total_wrapping_tax_excl'
			}
			#puts invoice
			expected_total.each_pair do |key, value_expected|
				expect(actual_total[mapping[key]].to_f).to eq value_expected.to_f
			end
		end
	end
end

scenario = JSON.parse File.read(ENV['PAT_SOURCE'])

describe 'Invoice test' do
	it 'should work' do
		test_invoice @shop, scenario, :dump_pdf_to => ENV['PAT_SOURCE'].sub(/\.json$/, '.pdf')
	end
end
