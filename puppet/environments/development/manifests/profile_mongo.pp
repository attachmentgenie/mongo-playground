class profile_mongo {

  class {'::mongodb::globals':
    manage_package_repo => true,
  }->
  class {'::mongodb::server': }->
  class {'::mongodb::client': }

  package { 'mongodb-org-tools' :
    ensure => 'present',
  }
}
