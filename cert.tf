resource "aws_acm_certificate" "self_signed" {
  private_key      = file("srekubecraft.key")
  certificate_body = file("srekubecraft.crt")

  tags = merge(local.tags, { Name = "self-signed-certificate" })
}
