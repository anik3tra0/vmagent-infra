provider "aws" {
  region = "ap-south-1"
  version = "~> 3.23"
}

resource "aws_security_group" "instance" {
  name = "terraform-datanode-instance"

  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "datanode-1" {
  ami           = "ami-04b1ddd35fd71475a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "datanode-1"
  }
}
