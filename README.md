Puppet Module: user\_ssh\_pubkey
================================

Collect users' SSH public keys and make available as facts, with the name
formatted as `<username>\_sshrsakey` or `<username>\_sshdsakey`. These facts
can then be collected as exported resources to populate `ssh_authorized_keys`
resources.

License
-------

Apache 2.0


Contact
-------

Wil Cooley <wcooley(at)nakedape.cc>

Support
-------

Please log tickets and issues at our [Projects
site](https://github.com/wcooley/puppet-user_ssh_pubkey/issues)
