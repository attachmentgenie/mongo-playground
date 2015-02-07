class profile_node {

  class { 'nodejs':
    manage_repo => true,
  } ->
  package { 'mongodb':
    ensure   => present,
    provider => 'npm',
  }
}
