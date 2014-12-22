class role_playground {

  class { '::profile_mongo': } ->
  class { '::profile_php': } ->
  class { '::profile_python': }
}