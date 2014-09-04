require 'rspec'
require 'puppetlabs_spec_helper/module_spec_helper'

# From puppetlabs-stdlib/spec/spec_helper.rb
RSpec.configure do |config|
  config.before(:all) do
    # Without this, Facter finds the user_ssh_pubkey set in my
    # ~/.facter/facts.d/
    if Facter::Util::Config.respond_to? :external_facts_dirs=
      Facter::Util::Config.external_facts_dirs = []
    else
      # rspec 2.99 does not like this but it is needed for Facter 1.7
      Facter::Util::Config.stubs(:external_facts_dirs).returns([])
    end
  end

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
