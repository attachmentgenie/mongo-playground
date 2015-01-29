class profile_ruby {

  package { 'ruby-devel':
    ensure   => present,
  } ->
  package { 'bson_ext':
    ensure   => present,
    provider => 'gem',
  } ->
  package { 'mongodb':
    ensure   => present,
    provider => 'gem',
  }
}
