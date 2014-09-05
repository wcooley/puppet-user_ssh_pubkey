require 'spec_helper'
require 'rspec-puppet-utils'

describe 'user_ssh_pubkey' do

  let(:facts) {{ :path => '/bin:/usr/bin' }}

  let!(:getpwnam) do
    MockFunction.new('getpwnam') do |f|
      f.stub.with(['jensenb']).returns({'dir' => '/u/jensenb'})
    end
  end

  context 'with no parameters' do
    let(:title) { 'jensenb/ssh-rsa@animalhouse.edu' }
    target = '/u/jensenb/.ssh/id_rsa'

    it 'should have an exec resource with expected parameters' do
      expect(subject).to contain_exec("ssh-keygen-#{title}") \
        .with_creates(target) \
        .with_user('jensenb') \
        .with_command("ssh-keygen -q  -t rsa -N '' -C '#{title}' -f '#{target}'")
    end
  end

  context 'with all parameters' do
    let(:title) { '@no-user-or-type.animalhouse.edu' }
    let(:params) do {
      :type => 'dsa',
      :user => 'jensenb',
      :target => '/var/tmp/jensenb/.ssh/id_dsa',
      :bits => '1024',
    }
    end

    it 'should have an exec resource with expected parameters' do
      expect(subject).to contain_exec("ssh-keygen-#{title}") \
        .with_creates('/var/tmp/jensenb/.ssh/id_dsa') \
        .with_user('jensenb') \
        .with_command("ssh-keygen -q -b 1024 -t dsa -N '' -C '#{title}' -f '/var/tmp/jensenb/.ssh/id_dsa'")
    end


  end

  context 'error caused by' do
    context 'relative target' do
      let(:title) { 'jensenb/ssh-rsa@animalhouse.edu' }
      let(:params) {{ :target => 'relative/path' }}
      it do
        expect { should compile }.to \
          raise_error(Puppet::Error, /not an absolute path/)
      end
    end

    context 'no user param or in title' do
      let!(:title) { '@animalhouse.edu' }
      let!(:params) {{ }}
      it do
        expect { should compile }.to \
          raise_error(Puppet::Error, /unable to determine user/)
      end
    end

    context 'no keytype param or in title' do
      let(:title) { 'jensenb@animalhouse.edu' }
      let(:params) {{ }}
      it do
        expect { should compile }.to \
          raise_error(Puppet::Error, /unable to determine type/)
      end
    end

  end

end
