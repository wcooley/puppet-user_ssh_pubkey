# == Define: user_ssh_pubkey
#
# Defined type to create SSH public keys for users.
#
# === Parameters
#
# [*name*]
#   The SSH key comment. Ideally this would be something like
#   "$user/ssh-$type@$::fqdn"; if so, the user and type parameters can be left
#   unspecified.
#
# [*user*]
#   *namevar* The user in whose home directory to create the key.
#
# [*target*]
#   The absolute filename base to store the private and public keys in. This
#   parameter should generally be avoided, as it breaks the facts.
#
# [*type*]
#   The key type: "dsa", "rsa", "ecdsa". Note that semantics of this parameter
#   are different from the `*_type` fact and "type" parameter for
#   `ssh_authorized_key`.
#
# [*user*]
#   The user account in which the SSH key should be generated.
#
# [*bits*]
#   The number of bits in the key. See `ssh-keygen(1)` for limits.
#
define user_ssh_pubkey (
  $type = undef,
  $user = undef,
  $target = undef,
  $bits = undef,
) {

  if $user {
    $real_user = $user
  }
  elsif $title =~ /^([^@\/]+)[\/]?/ { # Beginning of string to '/' or '@'
                                      # Extra [\/]? for syntax highlight fail
    $real_user = $1
  }
  else {
    fail("module=${module_name}", "error=\"unable to determine user\"")
  }

  if $type {
    $real_type = $type
  }
  elsif $title =~ /ssh-(\w+)/  {   # "Word" chars following "ssh-"
    $real_type = $1
  }
  else {
    fail("module=${module_name}", "error=\"unable to determine type\"")
  }

  if $target {
    $real_target = $target
  }
  else {
    # This is kinda naive, since this is user info on the master, which might
    # not be the same on the node.
    $userhash = getpwnam($real_user)
    $real_target = join([$userhash['dir'], '.ssh', "id_${real_type}"], '/')
  }

  validate_absolute_path($real_target)

  $f_target = "-f '${real_target}'"
  $b_bits = $bits ? { undef => '', default => "-b ${bits}" }
  $t_type = "-t ${real_type}"
  $C_comment = "-C '${title}'"

  exec { "ssh-keygen-${title}":
    command => "ssh-keygen -q ${b_bits} ${t_type} -N '' ${C_comment} ${f_target}",
    creates => $real_target,
    user    => $real_user,
    path    => $::path,
  }

}
