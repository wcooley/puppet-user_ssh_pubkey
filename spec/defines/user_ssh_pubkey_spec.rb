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
      it { should raise_error(Puppet::Error, /not an absolute path/) }
    end

    context 'no user param or in title' do
      let!(:title) { '@animalhouse.edu' }
      let!(:params) {{ }}
      it { should raise_error(Puppet::Error, /unable to determine user/) }
    end

    context 'no keytype param or in title' do
      let(:title) { 'jensenb@animalhouse.edu' }
      let(:params) {{ }}
      it { should raise_error(Puppet::Error, /unable to determine type/) }
    end

  end
end

# Re-defining the `getpwnam` mock seems to only work within a block not
# contained by a block already having `getpwnam` mocked)
describe 'user_ssh_pubkey' do
  context 'user does not exist' do
    let!(:getpwnam) do
      MockFunction.new('getpwnam') do |f|
        f.stub.with(['jensenb']).returns()
      end
    end

    context 'no target param given' do
      let(:title) { 'jensenb/ssh-rsa@animalhouse.edu' }
      it { should raise_error(Puppet::Error, /Unable to lookup user/) }
    end

    context 'target param given' do
      let(:title) { 'jensenb/ssh-rsa@animalhouse.edu' }
      let(:params) {{ :target => '/home/jensenb/.ssh/id_rsa' }}

      it 'should have an exec resource with expected parameters' do
        exec = contain_exec("ssh-keygen-#{title}")
        exec.with_creates('/home/jensenb/.ssh/id_rsa')
        exec.with_user('jensenb')
        exec.with_command("ssh-keygen -q  -t rsa -N '' -C '#{title}' -f '/home/jensenb/.ssh/id_rsa'")
        expect(subject).to(exec)
      end
    end
  end
end
