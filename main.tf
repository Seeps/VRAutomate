terraform {
    required_providers {        
        aws = {
    version = "~> 3.62.0"
        }
    }
}

provider "aws" {        
#AWS region
    region = "us-west-2" ##REVIEW - Change this to your preferred region
}

resource "tls_private_key" "tls-velo" {        
#Generation of private key for key pair
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "ssh-velo" {        
#Generation of public/private key pair - the public key will be registered with AWS to allow instance authentication
    key_name = "${var.case_name}"
    public_key = tls_private_key.tls-velo.public_key_openssh
}

resource "local_file" "private_key" {
#Save private key in PEM format with case name as the filename - needed to authenticate with instance
    content = tls_private_key.tls-velo.private_key_pem
    filename = "${var.case_name}.pem"
    file_permission = "0400"
}

resource "local_file" "ansible-inventory" {
#Created a file called 'inventory' which is an Ansible inventory file
    filename = "./inventory"
    content     = <<EOF
[ubuntu]
${aws_instance.instance-velo.public_ip}

[ubuntu:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=./${var.case_name}.pem
EOF
}

resource "aws_security_group" "secgroup-velo" {      
#Security group that allows inbound SSH and Velociraptor GUI access from your IP address; egress is open
    name = "${var.case_name}"
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    tags = {
        Name = "${var.case_name}"
    }
}

resource "aws_security_group_rule" "group-velo-ssh" {      
#This rule attaches to the created security group; it allows inbound SSH access to the instance from your IP only
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.secgroup-velo.id}"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
}

resource "aws_security_group_rule" "group-velo-frontend" {      
#This rule attaches to the created security group; it allows open inbound Velociraptor frontend access (agent/sensor checkin)
    type = "ingress"
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    security_group_id = "${aws_security_group.secgroup-velo.id}"
    cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "group-velo-gui" {      
#This rule attaches to the created security group; it allows inbound Velociraptor GUI access from your IP only
    type = "ingress"
    from_port = 8889
    to_port = 8889
    protocol = "tcp"
    security_group_id = "${aws_security_group.secgroup-velo.id}"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
}

resource "aws_instance" "instance-velo" {      
#Creates a Ubuntu 20 Server base instance; all resources created are tracked by the case name variable
    ami = "ami-03d5c68bab01f3496" ##REVIEW - Change the AMI ID for Ubuntu 20 Server depending on your region
    key_name = aws_key_pair.ssh-velo.key_name
    instance_type = "m5.large" ##REVIEW - Change the instance type to match your needs
    security_groups = [ "${var.case_name}" ]
    tags = {
        Name = "${var.case_name}"
    }
    root_block_device { ##REVIEW - Remove this block if you wish to keep the default instance type volume size
    volume_size = "1024"
    }
    provisioner "local-exec" {
#Populate variables into SSH command and append to velociraptor.sh script
    command = "echo $'\nssh -i ${var.case_name}.pem ubuntu@${aws_instance.instance-velo.public_ip}' >> velociraptor.sh"
}
}