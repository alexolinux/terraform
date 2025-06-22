terraform {
  backend "s3" {
    bucket = "cmd-rm-rf-ops-321"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
