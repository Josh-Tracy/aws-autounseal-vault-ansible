variable "ec2-instances-ue1a" {
  description = "Map instances to configurations"
  type = map(object({
    instance_type     = string
    environment       = string
    availability_zone = string
    key_name          = string
    ami               = string
    private_ips       = set(string)
    associate_with_private_ip = string
    tags              = map(string)
  }))
  default = {
     "vault-server" = {
       availability_zone = "us-east-1a",
       environment       = "dev",
       instance_type     = "t2.medium",
       key_name          = "ubuntu-dev-key",
       ami               = "ami-04505e74c0741db8d",
       private_ips       = ["10.0.1.51"],
       associate_with_private_ip = "10.0.1.50",
       tags = {
         "Name" = "vault-server",
         "OS" = "ubuntu",
	 "Application" = "vault",
        }

    }
  }
}

variable "keypairs" {
  description = "keypairs for ec2 instances"
  type = map(object({
    key_name = string
    public_key = string
    tags     = map(string)
  }))
  default = {
    "ubuntu-dev-key" = {
      key_name = "ubuntu-dev-key",
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOTMJkBnlxhsdgU7k4gQOUw9IZjdS45k0Y51J9CyjhFIRcnCOq7s9JKeOCUf2RBSCs7IvTRS77g+5fiVYq0hgqlvA4UqVqYOjPOUgq1f74y7UwytB3GAk8/0UJrAav8H1DIwtDrI3xg3+u2Kj00kUmtkZubY/vkqZIwIBh0NZBkF2vxTYgJ9waePA4c7HSVMQYg3gEFJFVrXutXLApg4EOD5g97HOjBKS+JeW06bjQqRGh+ZgPz6VSUew4zPIwIu8cIvs21w2/9kFNwUuATVmj4m2rA/0cPxeATefG93y8nRXX0aXpRnm3GuKggUyd+HlQPXeELL14YIF6TrauYjLgKfDDDmRINThmiNMvlnxRVwxsKbwoQotQE18TaEJGf+GotfBSSjH9FXghGzTkuXSkoR4v4Aq97TlqFp2Ohm7Tm3vizLhN5fh/VW4Tag0M+rV3WyuV3NDtlJOS0TNaEPpO9wHrmaPgdDrWTvom0HDElfHBsM6h4VIEOFpYDdqXxo0= professorhojo@shinra",
      tags = {
        "Name" = "ubuntu-dev-key",
      }
    }
  }
}
