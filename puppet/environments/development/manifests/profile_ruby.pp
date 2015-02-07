class profile_ruby {

  class { 'ruby':
    gems_version  => 'latest'
  } ->
  package { 'ruby-mongo':
    ensure   => present,
  }
}
