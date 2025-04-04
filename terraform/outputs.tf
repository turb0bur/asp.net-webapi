output "webapi_url" {
  value = "http://${aws_lb.webapi.dns_name}/swagger/index.html"
}
