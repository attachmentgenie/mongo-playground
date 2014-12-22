class profile_php {

  class { '::php':
    fpm          => false,
    extensions   => {'pecl-mongo' => {}},
  }
}