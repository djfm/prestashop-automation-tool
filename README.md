prestashop-automation-tool
==========================

This tool is designed to make selenium testing of PrestaShop shops really easy. It should work with any non-windows OS, but the preferred configuration is a Linux machine with apache2.

#Setup

##Prerequisites

You will need a working ruby environment:
```bash
sudo apt-get install ruby ruby-dev
```

And probably the mysql headers for the mysql2 gem to compile:
```bash
sudo apt-get install libmysqlclient-dev
```

##Installation

```bash
sudo gem install prestashop-automation-tool
```

#Usage

##First Steps

Browse to a local PrestaShop installation:
```bash
cd /var/www/prestashop
```

Initialize the environment:
```bash
pat init
```

This will try to guess the parameters needed from your installation files and ask about what's missing. When the small wizard is done you can edit the `pat.conf.json` file and correct it if necessary.

Enable some tests:
```bash
pat enable install
```

Run the tests:
```bash
pat test
```

The test command will run all tests under `tests-enabled`, but you can specify a specific file name to run.

##Creating a New Test

To create a test stub, just run this:
```bash
pat create my.test
```

This will put a new test called `my.test.rb` under `tests-enabled` containing something like:
```ruby
require 'prestashop-automation-tool/helper'

describe 'My first test' do
	it 'should login as a customer' do
		@shop.login_to_front_office
	end
end
```

Your test script receives automatically a `@shop` variable, which is an instance of [PrestaShopAutomation::PrestaShop](https://github.com/djfm/prestashop-automation/blob/master/lib/prestashop-automation.rb).

Look at the modules under [prestashop-automation/lib/actions](https://github.com/djfm/prestashop-automation/tree/master/lib/actions) to see what you can do with this shop!
