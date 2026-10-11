output "api_docs_url" {
  value = "http://${aws_instance.chatbot_server.public_ip}:8000"
}
