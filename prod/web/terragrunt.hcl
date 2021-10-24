dependency "network" {
  config_path = "../network"
}
dependency "security_group" {
  config_path = "../security_group"
}


include {
  path = find_in_parent_folders()
}
