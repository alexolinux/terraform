# Output
output "ec2_instance_id" {
  value = aws_instance.this.id
}

output "ec2_private_ip" {
  value = aws_instance.this.private_ip
}

output "ec2_public_ip" {
  value = aws_instance.this.public_ip
}

output "ec2_az" {
  value = aws_instance.this.availability_zone
}

output "ec2_instance_type" {
  value = aws_instance.this.instance_type
}

output "ec2_security_group" {
  value = aws_security_group.ec2.id
}

output "ec2_key_pair" {
  value = aws_key_pair.this.key_name
}
