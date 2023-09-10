provider "aws" {
  region  = var.region
  profile = "playground"

  default_tags {
    tags = {
      Environment = var.environment
      Product     = var.product
    }
  }
}

provider "tls" {
}
