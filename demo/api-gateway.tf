resource "aws_api_gateway_rest_api" "demo-gateway" {
    name        = "demoApiGateway"
    description = "Terraform Lambda Container Application Example with python app"
}

resource "aws_api_gateway_resource" "number" {
    parent_id   = aws_api_gateway_rest_api.demo-gateway.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
    path_part   = "{${var.resource_name}+}"
}

resource "aws_api_gateway_method" "number" {
    rest_api_id   = aws_api_gateway_rest_api.demo-gateway.id
    resource_id   = aws_api_gateway_resource.number.id
    http_method   = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambdapy" {
    rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
    resource_id = aws_api_gateway_method.number.resource_id
    http_method = aws_api_gateway_method.number.http_method

    integration_http_method = "POST"
    type                    = "AWS"
    uri                     = aws_lambda_function.demo-lambda-function.invoke_arn
    passthrough_behavior = "WHEN_NO_TEMPLATES"
    timeout_milliseconds = 29000
   
    request_templates = {
        "application/json" = <<EOF
{
  "hour" : $input.params('hour')
}
EOF
  }
}

resource "aws_api_gateway_method" "number_root" {
    rest_api_id   = aws_api_gateway_rest_api.demo-gateway.id
    resource_id   = aws_api_gateway_rest_api.demo-gateway.root_resource_id
    http_method   = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
    rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
    resource_id = aws_api_gateway_method.number_root.resource_id
    http_method = aws_api_gateway_method.number_root.http_method

    integration_http_method = "POST"
    type                    = "AWS"
    uri                     = aws_lambda_function.demo-lambda-function.invoke_arn
#   passthrough_behavior = "WHEN_NO_TEMPLATES"
#   request_templates = {
#    "application/json" = <<EOF
#{"hour" : $input.params('hour')}
#EOF
# }
    timeout_milliseconds = 29000
}

resource "aws_api_gateway_method_response" "response_200" {
    rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
    resource_id = aws_api_gateway_resource.number.id
    http_method = aws_api_gateway_method.number.http_method
    status_code = "200"
 
    response_models = { "application/json" = "Empty"}
}

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
    depends_on = [
     aws_api_gateway_integration.lambdapy,
     aws_api_gateway_integration.lambda_root,
    ]
    rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
    resource_id = aws_api_gateway_resource.number.id
    http_method = aws_api_gateway_method.number.http_method
    status_code = aws_api_gateway_method_response.response_200.status_code
    # Transforms the backend JSON response to json. The space is "A must have"
    response_templates = {
 "application/json" = <<EOF
 
 EOF
 }
}

# Model
# resource "aws_api_gateway_model" "MyDemoModel" {
#   rest_api_id = "${aws_api_gateway_rest_api.demo-gateway.id}"
#   name = "usermodel"
#   description = "a JSON schema"
#   content_type = "application/json"
# 
#   #the payload of the POST request
#   schema = <<EOF
# {
# "$schema": "http://json-schema.org/draft-04/schema#",
# "title": "usermodel",
# "type": "object",
# "properties": 
# {
# "callerName": { "type": "string" }
# }
# 
# }
# EOF
#}

resource "aws_api_gateway_deployment" "demo-gateway" {
    depends_on = [
        aws_api_gateway_integration.lambdapy,
        aws_api_gateway_integration_response.IntegrationResponse,
    ]

    rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
    stage_name  = var.stage
}

output "base_url" {
    value = "${aws_api_gateway_deployment.demo-gateway.invoke_url}/${var.resource_name}"
}