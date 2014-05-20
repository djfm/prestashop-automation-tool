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

Browse to a local PrestaShop installation:
```bash
cd /var/www/prestashop
```

Initialize the environment:
```bash
pat init
```

This will try to guess the parameters needed from your installation files and ask about what's missing. When the small wizard is done you can edit the pat.conf.json file and correct it if necessary.

Enable some tests:
```bash
pat enable install
```

Run the tests:
```bash
pat test
```
