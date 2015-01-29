class profile_node {

  class { 'nodejs': }

  package { 'nodejs-mongodb':
    ensure   => present,
  }
}
