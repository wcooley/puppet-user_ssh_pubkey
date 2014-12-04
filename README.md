Puppet module: user\_ssh\_pubkey
================================

[![Build
Status](https://travis-ci.org/wcooley/puppet-user_ssh_pubkey.svg?branch=master)](https://travis-ci.org/wcooley/puppet-user_ssh_pubkey)

Generate user SSH keys on nodes and make public keys available as facts. These
facts can then be collected as exported resources to populate
`ssh_authorized_key` resources.

Note that, with this workflow, the agent will have to run twice before the
keys are available -- facts are collected before resources are created, so the
first time through the keypair will be generated and the second time the
public key will be available as a fact.

Note, that, also populating the `user_ssh_pubkey` external fact is (currently)
unimplemented.

Facts
-----

Facts with the following formats are created, which correspond with the
parameters for the `ssh_authorized_key` type:

* `<username>_ssh(rsa|dsa)key`
* `<username>_ssh(rsa|dsa)key_comment`
* `<username>_ssh(rsa|dsa)key_type`

The list of users whose public keys are to be collected as facts is configured
by the `user_ssh_pubkey` fact, which can be set using external facts. For
example:

    $ cat /etc/facter/facts.d/user_ssh_pubkey.yaml
    ---
    user_ssh_pubkey: jensenb,alice,bob

Type
----

Type `user_ssh_pubkey` can be used to generate DSA or RSA keys on nodes.
Parameters are consistent with parameters for `ssh_authorized_key` where
possible.

Currently this is implemented as a Puppet defined type, which results in an
`exec` type which runs `ssh-keygen`.

Keys are generated with null passphrases.

### Parameters

- **name**
    The SSH key comment. Ideally this would be something like
    "$user/ssh-$type@$::fqdn"; if so, the user and type parameters can be left
    unspecified.

- **user**
    **namevar** The user in whose home directory to create the key.

- **target**
    The absolute filename base to store the private and public keys in. This
    parameter should generally be avoided, as it breaks the facts.

- **type**
    The key type: "dsa", "rsa", "ecdsa". Note that semantics of this parameter
    are different from the `*_type` fact and "type" parameter for
    `ssh_authorized_key`.

- **user**
    The user account in which the SSH key should be generated.

- **bits**
    The number of bits in the key. See `ssh-keygen(1)` for limits.

Example
-------

For the source or client node, generate an SSH key, collect the fact and
create an exported `ssh_authorized_key` resource:

```
user_ssh_pubkey { "repocloner/ssh-rsa@${::fqdn}": }

file { '/etc/facter/facts.d/user_ssh_pubkey.txt':
  ensure  => present,
  content => "user_ssh_pubkey=repocloner\n",
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
}

if $::repocloner_sshrsakey {
  @@ssh_authorized_key { $::repocloner_sshrsakey_comment:
    ensure => present,
    key    => $::repocloner_sshrsakey,
    user   => 'repocloner',
    type   => $::repocloner_sshrsakey_type,
    tag    => [ 'repocloner-ssh-key' ],
  }
}

```

If the client node's name is used in the name (comment) of the
`user_ssh_pubkey`, then exported resources from multiple client
nodes can be generated.

For the target or server node, collect the exported resource:

```
Ssh_authorized_key <<| tag == 'repocloner-ssh-key' |>>
```

One could also use `user` parameter instead of a tag for selecting the
exported resources instead of a tag.

License
-------

Apache 2.0

Contact
-------

Wil Cooley <wcooley(at)nakedape.cc>

Support
-------

Please log tickets and issues at our [Github
issues](https://github.com/wcooley/puppet-user_ssh_pubkey/issues).
