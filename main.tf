terraform {
  required_version = ">= 0.11.0"
}

variable "vault_addr" {
  description = "vault address"
  default = "http://mattspeters-benchmark-vault-elb-1366644832.us-east-1.elb.amazonaws.com:8200/"
  }

# Set VAULT_TOKEN environment variable
provider "vault" {
  address = "${var.vault_addr}"
  max_lease_ttl_seconds = 1500
}

# AWS credentials from Vault
# Must set up AWS backend in Vault on path aws with role deploy
data "vault_aws_access_credentials" "aws_creds" {
  backend = "aws-tf"
  role = "deploy"
}

provider "aws" {
  region = "${var.aws_region}"
  access_key = "${data.vault_aws_access_credentials.aws_creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.aws_creds.secret_key}"
}

resource "aws_instance" "ubuntu" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_region}a"
  key_name = "mattpeters"
}
