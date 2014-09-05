require 'rspec'
# Disable external fact loader
# Facter 1.7 needs to require facter; 2.2 does not. Remove when support for 1.7
# is dropped.
require 'facter'
require 'facter/application'
Facter::Application.create_nothing_loader
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.before(:each) do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter::Util::Loader.any_instance.stubs(:load_all)
  end

  config.after :each do
    Facter.clear
    Facter.clear_messages
  end
end
