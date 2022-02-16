terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/* MAIN INSTANCE */

resource "aws_instance" "wordpress" {
  ami                    = "ami-0a8b4cd432b1c3063"
  count                  = var.instance_count
  availability_zone      = var.zones[count.index]
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  user_data = templatefile("file.sh.tpl", {
    hostname = aws_db_instance.mysql_db.endpoint
    db_name  = aws_db_instance.mysql_db.name
    username = aws_db_instance.mysql_db.username
    password = aws_db_instance.mysql_db.password
  })
  key_name = aws_key_pair.kp.id
  tags = {
    Name = "Wordpress"
  }
  depends_on = [
    aws_db_instance.mysql_db
  ]

}

output "wordpress_ip" {
  value       = aws_elb.clb.dns_name
  description = "The public IP address of the main server instance."
}
