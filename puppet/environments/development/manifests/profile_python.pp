class profile_python {

  class { 'python' :
    dev => true,
  } ->
  package { 'python-pymongo':
    ensure => 'present',
  }
}
