resource "aws_security_group" "additional" {
  name        = "k8s-test-sg"
  description = "k8s test sg"
  vpc_id      = data.aws_vpc.test_k8s_vpc.id
}
