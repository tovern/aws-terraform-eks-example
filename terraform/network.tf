# Foundation network

module "network" {
  source = "./modules/network"

  name        = "${var.environment}-network"
  product     = var.product
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
}
