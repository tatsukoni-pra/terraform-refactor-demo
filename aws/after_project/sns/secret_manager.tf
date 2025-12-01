resource "aws_secretsmanager_secret" "tatsukoni_test_secret" {
  name        = "tatsukoni-test-secret"
  description = "Tatsukoni Test Secret"

  tags = {
    Name = "tatsukoni-test-secret"
  }
}
