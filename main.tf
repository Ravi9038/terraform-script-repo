
# provider "aws" {
#   region = "us-east-2"
# }

provider "github" {
  # token = github_token

}

# resource "github_repository" "terraform-script-repo" {
#   name        = "terraform-script-repo"
#   description = "An example repository created with Terraform"
#   # private     = false
#   visibility = "public"

#   lifecycle {
#     prevent_destroy = true
#   }


# }

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
data "aws_instance" "app_server" {
  instance_id = aws_instance.app_server.id
}
data "aws_subnet" "subnet" {
  id = aws_instance.app_server.subnet_id
}


