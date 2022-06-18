resource "aws_instance" "datanode" {
  count                  = var.nodes
  ami                    = "ami-096b9cd38d837f984"
  key_name               = "totem-deployer"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.ingress-datanode.id]
  subnet_id              = aws_subnet.subnet-uno.id

  user_data = <<-EOF
              #!/bin/bash

              wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
              tar xvfz node_exporter-*.*-amd64.tar.gz
              cd node_exporter-*.*-amd64
              ./node_exporter &
              EOF

  tags = {
    Name        = "datanode-${count.index + 1}"
    service     = "datanode"
    namespace   = "node-exporter"
    environment = "production"
  }
}

resource "aws_instance" "vmagent" {
  count                  = var.vmagent_instances
  ami                    = var.ami
  key_name               = var.keypair
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2-trustee-profile.name
  vpc_security_group_ids = [
    aws_security_group.ingress-vmagent.id]
  subnet_id              = aws_subnet.subnet-uno.id

  user_data = <<-EOF
              #!/bin/bash

              which docker || (curl -fsSL https://get.docker.com \
              -o /tmp/get-docker.sh && \
              sudo sh /tmp/get-docker.sh)

              docker-compose --version || (sudo curl -L "https://github.com/docker/compose/releases/download/v2.1.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose)

              sudo apt-get install -y uidmap

              sudo sh -eux echo <<EOF export DOCKER_HOST=unix:///run/user/1000/docker.sock" > /etc/profile.d/docker.sh EOF

              . /etc/profile.d/docker.sh

              docker ps || dockerd-rootless-setuptool.sh install

              systemctl --user enable docker

              sudo loginctl enable-linger $(whoami)


              grep -i "live-restore" /etc/docker/daemon.json || (\
              echo '{"live-restore": true}' | sudo tee /etc/docker/daemon.json && \
              sudo systemctl reload docker && \
              systemctl --user reload docker)


              mkdir -p ~/vmagent && cd ~/vmagent && touch docker-compose.yaml && touch vmagent.yaml

              EOF

  tags = {
    Name        = "vmagent-${count.index + 1}"
    service     = "vmagent"
    namespace   = "metric-dispatcher"
    environment = "production"
  }
}

resource "aws_eip" "ip-prod-env" {
  count    = var.nodes
  instance = aws_instance.datanode[count.index].id
  vpc      = true
}

resource "aws_eip" "ip-prod-env-vm-agent" {
  count = var.vmagent_instances
  instance = aws_instance.vmagent[count.index].id
  vpc      = true
}
