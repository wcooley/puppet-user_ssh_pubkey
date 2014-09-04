require 'rspec'
# This has to be before the puppetlabs_spec_helper to be effective. I do not
# understand why.
RSpec.configure { |c| c.mock_with :rspec }
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
      Facter::Util::Config.stub(:external_facts_dirs).and_return([])
    end
  end

  config.before(:each) do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter::Util::Loader.any_instance.stub(:load_all)
  end

  config.after :each do
    Facter.clear
    Facter.clear_messages
  end
end
