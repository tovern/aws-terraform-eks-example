resource "aws_secretsmanager_secret" "admin_creds" {
  name                    = "${var.environment}/admin_creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "db_creds" {
  name                    = "${var.environment}/db_creds"
  recovery_window_in_days = 0
}

resource "tls_private_key" "frontend" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "simple_python_rest_frontend" {
  private_key_pem = tls_private_key.frontend.private_key_pem

  subject {
    common_name  = "test.simple-python-rest.com"
    organization = "My Org"
  }

  validity_period_hours = 1200

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "simple_python_rest_frontend_cert" {
  private_key      = tls_private_key.frontend.private_key_pem
  certificate_body = tls_self_signed_cert.simple_python_rest_frontend.cert_pem

}
