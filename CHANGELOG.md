2016-10-24 - Release 1.0.0
--------------------------

Bugfixes:

* #11 Puppet 4 compatibility due to new rule against uppercase letters as
first character of identifiers.
* #13 Tests work again.

Enhancement:

* #1, #10, #17 Support ECDSA keys.
* #13 Test against Ruby 2.1.9.
* #13 Test against Puppet 4.
* #9 Include example usage.

Incompatibilities:

* #13 Drop support for Ruby 1.8.7. (We no longer test against but it might
work.)
* #13 Drop support for Puppet 2.7. (We no longer test against but it might
work.)


2014-10-11 - Release 0.2.2
--------------------------

Bugfixes:

* Correct module metadata for dependency versions.
* Update URLs after renaming Github project.

2014-09-05 - Release 0.2.0
--------------------------

Features:

* Add defined type `user_ssh_pubkey` to generate SSH keys on nodes. (#3)

Bugfixes:

* Facts support SSH keys with whitespace in the comment. (#2)
* Include module metadata for supported OS, required modules.

2014-09-03 - Release 0.1.0
--------------------------

Features:

* Intial release.
