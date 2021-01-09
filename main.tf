provider "aws" {
  region = "ap-south-1"
  version = "~> 3.23"
}

resource "aws_instance" "datanode-1" {
  ami           = "ami-04b1ddd35fd71475a"
  instance_type = "t2.micro"

  tags = {
    Name = "datanode-1"
  }
}
