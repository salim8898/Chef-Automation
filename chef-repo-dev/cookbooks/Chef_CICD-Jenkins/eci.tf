provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "poc-demo" {
  ami           = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"
  key_name      = "saleem"
  subnet_id = "subnet-034df0aed87004101"
  security_groups = ["sg-0871fe2696d85a737"]
  tags          = {
     Name       = "poc-client-salim_team101"
          }
  provisioner "local-exec" {
    command = "echo ${aws_instance.poc-demo.public_ip} >> /tmp/public_ips.txt"
  }
}
