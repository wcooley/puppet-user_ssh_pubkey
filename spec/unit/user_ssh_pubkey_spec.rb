require 'spec_helper'
require 'facter'
require 'ostruct'

def mock_pubkeys_for_user(username)

  user_struct = OpenStruct.new(:dir => "/u/#{username}")
  rsa_file = "#{user_struct.dir}/.ssh/id_rsa.pub"
  dsa_file = "#{user_struct.dir}/.ssh/id_dsa.pub"

  Etc.stub(:getpwnam).with(username).and_return(user_struct)
  FileTest.stub(:exists?).with(rsa_file).and_return(true)
  FileTest.stub(:exists?).with(dsa_file).and_return(false)

  Facter::Util::FileRead.stub(:read).with(rsa_file) \
    .and_return("ssh-rsa #{username}_xxxlongkeyherexxx #{username}@zeus")
end

def load_fact(fact)
  # Adapted from puppetlabs-stdlib/spec/unit/facter/pe_version_spec.rb
  if Facter.collection.respond_to? :load     # Facter 2.x
    Facter.collection.load(fact)
  else                                       # Facter 1.x
    Facter.collection.loader.load(fact)
  end
end

describe 'Facter::Util::Fact' do
  before(:all) do
    load_fact(:user_ssh_pubkey)
  end

  context 'Facter::UserSshPubkey.add_facts_for_user' do

    it 'looks up SSH keys for a single user' do
      mock_pubkeys_for_user('jensenb')

      Facter::UserSshPubkey.add_facts_for_user('jensenb')

      expect(Facter.fact(:jensenb_sshrsakey).value).to \
        eq('jensenb_xxxlongkeyherexxx')
      expect(Facter.fact(:jensenb_sshrsakey_comment).value).to \
        eq('jensenb@zeus')
      expect(Facter.fact(:jensenb_sshrsakey_type).value).to eq('ssh-rsa')
    end
  end

  context 'Facter::UserSshPubkey.add_facts' do

    it 'does nothing without pre-existing fact user_ssh_pubkey' do

      Facter.stub(:value).with('user_ssh_pubkey').and_return(nil)
      # Facter will generate a warning that no facts are loaded, which is
      # actually what we want.
      Facter.should_receive(:warnonce).with(/^No facts loaded/).once

      Facter::UserSshPubkey.add_facts

      expect(Facter.fact('user_ssh_pubkey')).to be_nil
    end

    it 'looks up SSH keys for a single user from the user_ssh_pubkey fact' do

      Facter.stub(:value).with('user_ssh_pubkey').and_return('jensenb')
      mock_pubkeys_for_user('jensenb')

      Facter::UserSshPubkey.add_facts

      expect(Facter.fact(:jensenb_sshrsakey).value).to eq('jensenb_xxxlongkeyherexxx')
      expect(Facter.fact(:jensenb_sshrsakey_comment).value).to eq('jensenb@zeus')
      expect(Facter.fact(:jensenb_sshrsakey_type).value).to eq('ssh-rsa')
    end

    it 'looks up SSH keys for multiple users from the user_ssh_pubkey fact' do

      Facter.stub(:value).with('user_ssh_pubkey') \
        .and_return('jensenb,juser,auser')
      mock_pubkeys_for_user('jensenb')
      mock_pubkeys_for_user('juser')
      mock_pubkeys_for_user('auser')

      Facter::UserSshPubkey.add_facts

      expect(Facter.fact(:jensenb_sshrsakey).value).to eq('jensenb_xxxlongkeyherexxx')
      expect(Facter.fact(:jensenb_sshrsakey_comment).value).to eq('jensenb@zeus')
      expect(Facter.fact(:jensenb_sshrsakey_type).value).to eq('ssh-rsa')

      expect(Facter.fact(:juser_sshrsakey).value).to eq('juser_xxxlongkeyherexxx')
      expect(Facter.fact(:juser_sshrsakey_comment).value).to eq('juser@zeus')
      expect(Facter.fact(:juser_sshrsakey_type).value).to eq('ssh-rsa')

      expect(Facter.fact(:auser_sshrsakey).value).to eq('auser_xxxlongkeyherexxx')
      expect(Facter.fact(:auser_sshrsakey_comment).value).to eq('auser@zeus')
      expect(Facter.fact(:auser_sshrsakey_type).value).to eq('ssh-rsa')
    end
  end
end
