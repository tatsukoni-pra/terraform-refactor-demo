resource "aws_sns_topic" "tatsukoni_test_topic" {
  name = "tatsukoni-test-topic"

  tags = {
    Name = "tatsukoni-test-topic"
  }
}
