provider "osc" {
  access_key_id          = var.osc_key_id
  secret_key_id          = var.osc_secret_key
  region                 = "eu-west-2"
  skip_region_validation = true
  endpoints {
    ec2 = "https://fcu.eu-west-2.outscale.com"
    elb = "https://lbu.eu-west-2.outscale.com"
    s3  = "https://osu.eu-west-2.outscale.com"
    iam = "https://eim.eu-west-2.outscale.com"
  }
}

# Network
resource "osc_vpc_dhcp_options" "zone_options" {
  domain_name_servers = ["1.1.1.1", "8.8.8.8"]
  ntp_servers         = ["46.231.146.12", "46.231.144.179"]
}

resource "osc_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "osc_subnet" "host" {
  vpc_id            = osc_vpc.default.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
}

resource "osc_vpc_dhcp_options_association" "vpc_zone_options" {
  vpc_id          = osc_vpc.default.id
  dhcp_options_id = osc_vpc_dhcp_options.zone_options.id
}

resource "osc_internet_gateway" "gw" {
  vpc_id = osc_vpc.default.id
}

resource "osc_eip" "internet-nat" {
  vpc = true
}

resource "osc_nat_gateway" "nat-gateway" {
  allocation_id = osc_eip.internet-nat.id
  subnet_id     = osc_subnet.host-subnet.id
  depends_on    = [osc_internet_gateway.gw]
}

resource "osc_route_table" "nat-route-table" {
  vpc_id = osc_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = osc_internet_gateway.gw.id
    nat_gateway_id = osc_nat_gateway.nat-gateway.id
  }
  tags = {
    Name = "NAT Routing"
  }
}

resource "osc_route_table_association" "nat-route-table-assoc" {
  subnet_id      = osc_subnet.host-subnet.id
  route_table_id = osc_route_table.nat-route-table.id
}

resource "osc_security_group" "ssh_icmp" {
  name        = "sg_ssh_icmp"
  description = "Allow incoming SSH and ICMP connections"
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 1
    to_port     = 24
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 26
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 1
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = osc_vpc.default.id
  tags = {
    Name = "SSH and ICMP opening"
  }
}

# Security
resource "osc_key_pair" "deployer" {
  key_name   = "terraform_deployer"
  public_key = file("ssh/id_rsa.pub")
}

# Instance and boot
data "template_file" "nodes-bootstrap" {
  template = file("instances/bootstrap.sh.tpl")
  vars = {
    sc_region    = var.sc_region
    sc_node_type = "node"
  }
}

data "template_cloudinit_config" "nodes" {
  # When using outscale tags for hypervisor affinity, no encoding possible
  # as TINA (their hypervisor) needs data in plain format
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.nodes-bootstrap.rendered
  }
}

resource "osc_instance" "node" {
  availability_zone = "eu-west-2a"
  ami               = "ami-976177b8"
  instance_type     = "tinav5.c2r8p2"
  key_name          = osc_key_pair.deployer
  subnet_id         = osc_subnet.host.id
  vpc_security_group_ids = [
    osc_security_group.ssh_icmp.id,
  ]
  user_data = data.template_cloudinit_config.nodes.rendered
  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
  tags = {
    Name = "Hosting node"
    role = "node"
  }
}

# Storage
resource "osc_ebs_volume" "storage" {
  availability_zone = "eu-west-2a"
  type              = "gp2"
  size              = 100
  tags = {
    Name = "Storage"
    type = "Storage"
  }
}

resource "osc_ebs_volume" "swap" {
  availability_zone = "eu-west-2a"
  type              = "io1"
  size              = 40
  iops              = 3000
  lifecycle {
    ignore_changes = [
      iops,
    ]
  }
  tags = {
    Name = "Swap"
    type = "swap"
  }
}

resource "osc_volume_attachment" "nodes-docker-01-attachment" {
  device_name = "/dev/xvdb"
  volume_id   = osc_ebs_volume.storage.id
  instance_id = osc_instance.node.id
  lifecycle {
    ignore_changes = [
      volume_id,
      instance_id,
    ]
  }
}

resource "osc_volume_attachment" "nodes-swap-attachment" {
  device_name = "/dev/xvdx"
  volume_id   = osc_ebs_volume.swap.id
  instance_id = osc_instance.node.id
  lifecycle {
    ignore_changes = [
      volume_id,
      instance_id,
    ]
  }
}
