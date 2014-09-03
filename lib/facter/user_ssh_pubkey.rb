# Fact: <username>_ssh(rsa|dsa)key,
#       <username>_ssh(rsa|dsa)key_comment,
#       <username>_ssh(rsa|dsa)key_type
#
# Purpose:
#   Collect users' SSH public keys (presumably for exported resources).
#
# Resolution:
#   Reads a list of user names from *user_ssh_pubkey* fact and creates Facts
#   of their keys. The *user_ssh_pubkey* fact can be set with an external fact.
#

require 'etc'
require 'facter/util/file_read'

users_fact = Facter.value('user_ssh_pubkey')
users = users_fact ? users_fact.split(',') : []

users.each do |username|
  Facter.debug("Looking for SSH keys for user '#{username}'")
  user= Etc.getpwnam(username)
  sshdir = File.join(user.dir, '.ssh')

  [ 'rsa', 'dsa' ].each do |keytype|
    pubfile = "id_#{keytype}.pub"
    pubpath = File.join(sshdir, pubfile)

    if FileTest.exists?(pubpath)
      Facter.debug("Found '#{pubpath}' for user '#{username}'")
      ktype, key, comment = Facter::Util::FileRead.read(pubpath).chomp.split
      fact_base = "#{username}_ssh#{keytype}key"

      Facter.add(fact_base) do
        setcode { key }
      end

      Facter.add("#{fact_base}_comment") do
        setcode { comment }
      end

      Facter.add("#{fact_base}_type") do
        setcode { ktype }
      end
    else
      Facter.debug("Did not find '#{pubpath}' for user '#{username}'")
    end
  end
end
