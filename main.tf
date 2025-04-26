
# provider "aws" {
#   region = "us-east-2"
# }

provider "github" {
  # token = github_token

}

resource "github_repository" "terraform-script-repo" {
  name        = "terraform-script-repo"
  description = "An example repository created with Terraform"
  # private     = false
  visibility = "public"

  lifecycle {
    prevent_destroy = true
  }


}

# resource "aws_instance" "app_server" {
#   ami           = "ami-060a84cbcb5c14844"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ExampleAppServerInstance"
#   }
# }

