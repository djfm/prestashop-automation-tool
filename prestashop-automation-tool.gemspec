Gem::Specification.new do |s|
	s.name = 'prestashop-automation-tool'
	s.version = '0.5'
	s.date = '2014-05-19'
	s.description = "Automate prestashop."
	s.summary = 'This tool helps you add selenium tests to an existing prestashop installation.'
	s.authors = ["François-Marie de Jouvencel"]
	s.email = 'fm.de.jouvencel@gmail.com'
	s.files = Dir.glob("{lib,spec}/**/*")
	s.require_paths = ["lib"]
	s.homepage = 'https://github.com/djfm/prestashop-automation-tool'
	s.license = 'OSL'
	s.add_runtime_dependency 'prestashop-automation'
	s.add_runtime_dependency 'pry'
	s.add_runtime_dependency 'apache-vhosts-parser'
	s.executables << 'pat'
	s.executables << 'pat-runner-invoice.rb'
end
