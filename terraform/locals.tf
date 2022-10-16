locals {
  prefix              = "demo"
  app_dir             = "api"
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${local.prefix}-demo-lambda-container"
  ecr_image_tag       = "latest"
}
 
