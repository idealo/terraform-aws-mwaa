plugin "terraform" {
  enabled = true
  preset  = "recommended"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.5.0"
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.27.0"
}
