resource "aws_secretsmanager_secret" "tatsukoni_test_secret_v2" {
  name        = "tatsukoni-test-secret-v2"
  description = "Tatsukoni Test Secret v2"

  tags = {
    Name = "tatsukoni-test-secret-v2"
    Env  = "dev"
  }
}
