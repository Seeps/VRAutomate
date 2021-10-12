output "aws_private_ip" {       
#Output AWS instance private IP to standard out (command terminal)
#Can be used right away to SSH/RDP/WINRM into instance
    value = aws_instance.instance-velo.private_ip
}

output "aws_public_ip" {       
#Output AWS instance private IP to standard out (command terminal)
#Can be used right away to SSH/RDP/WINRM into instance
    value = aws_instance.instance-velo.public_ip
}