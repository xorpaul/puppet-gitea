# Class: gitea::user
# ===========================
#
# Manages user for the `::gitea` class.
#
# Parameters
# ----------
#
# * `manage_user`
# Should we manage provisioning the user? Default: true
#
# * `manage_group`
# Should we manage provisioning the group? Default: true
#
# * `manage_home`
# Should we manage provisioning the home directory? Default: true
#
# * `owner`
# The user owning gitea and its files. Default: 'git'
#
# * `group`
# The group owning gitea and its files. Default: 'git'
#
# * `home`
# Qualified path to the users' home directory. Default: empty
#
# * `group_gid`
# The gid of the group owning gitea and its files. Default: empty
#
# * `owner_uid`
# The uid of the user owning gitea and its files. Default: empty
#
# Authors
# -------
#
# Daniel S. Reichenbach <daniel@kogitoapp.com>
#
# Copyright
# ---------
#
# Copyright 2016-2019 Daniel S. Reichenbach <https://kogitoapp.com>
#
class gitea::user (
  Boolean $manage_user         = $gitea::manage_user,
  Boolean $manage_group        = $gitea::manage_group,
  Boolean $manage_home         = $gitea::manage_home,
  String  $owner               = $gitea::owner,
  String  $group               = $gitea::group,
  Optional[String] $home       = $gitea::home,
  Optional[Integer] $group_gid = $gitea::group_gid,
  Optional[Integer] $owner_uid = $gitea::owner_uid,
) {

  if ($manage_home) {
    if $home == undef {
      $homedir = "/home/${owner}"
    } else {
      $homedir = $home
    }
  }

  if ($manage_group) {
    group { $group:
      ensure => present,
      system => true,
      gid    => $group_gid,
    }
  }

  if ($manage_user) {
    user { $owner:
      ensure     => present,
      uid        => $owner_uid,
      gid        => $group,
      home       => $homedir,
      managehome => $manage_home,
      system     => true,
      require    => Group[$group],
    }
  }
}
