class role_playground {

  class { '::profile_mongo': } ->
  class { '::profile_node': } ->
  class { '::profile_php': } ->
  class { '::profile_python': } ->
  class { '::profile_ruby': } ->
  class { '::profile_docker': }
}
