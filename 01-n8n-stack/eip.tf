# Criando e associando um Elastic IP à instância
resource "aws_eip" "this" {
  domain   = "vpc"
  instance = aws_instance.this.id

  tags = {
    Name = "${var.aws_instance_name}-eip"
  }
}