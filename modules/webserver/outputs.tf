output "public-ip"{

    value = aws_instance.myapp-server1.public_ip
 }