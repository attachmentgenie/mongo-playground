class profile_python {

  class { 'python' :
    dev        => true,
  }
  python::pip { 'pymongo': }
}