Facter facts: user\_ssh\_pubkey
================================

[![Build
Status](https://travis-ci.org/wcooley/facter-user_ssh_pubkey.svg?branch=master)](https://travis-ci.org/wcooley/facter-user_ssh_pubkey)

Collect users' SSH public keys and make available as facts. These facts
can then be collected as exported resources to populate `ssh_authorized_key`
resources.

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

License
-------

Apache 2.0

Contact
-------

Wil Cooley <wcooley(at)nakedape.cc>

Support
-------

Please log tickets and issues at our [Github
issues](https://github.com/wcooley/facter-user_ssh_pubkey/issues).
