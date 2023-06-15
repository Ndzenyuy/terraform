terraform {
  /*cloud {
    organization = "Sparxinc"

    workspaces {
      name = "Provisionners"
    }
  }*/

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.3.0"
    }
  }

}

data "aws_vpc" "main" {
  id = "vpc-0c9f2f0452bdd7a0e"
}

data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

provider "aws" {
  # Configuration options
  region = local.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43lN30BOh8NwSqFhWwBwWcIuoIWnnD2ytPY4cOWvd4bxWBQWcguqSSWgjz3mVgMxqmuSp+9st/wxQ55/3VcbzolrPBBhCb1XivR56Rt14u0RD9YwkBfTEYJ3sWbSMndbFBOSI40oKEG/Y5b+Whn4R0vV2Gi/sEy/ydIGrGelv/Lb0QKsgkRFKWWk+/7uEdFi1FFRmq3k/XyiyYamrpUtbZ9n63R2VL8RQzOASpL0RrdDRKYHP5s1aI3uYH9YwT7xNM3AfqQGOyGRb+Q0P927YT/AfGZ7mZpAo0wp7xgk6hsag2uhCZvCQhmORQtiT/JGM7B4E3pyGthD53qxTb76kFxodt5fSIAQ9ydF0vpKuKBx3Uj+dQjt9JPLAJXn6bBB3fqp+FrHS+sGCtkwekmEWo3akmG5MceOcz2aeAQfGSh0MXGjSkj5UV/PiSFvHSysc0v2sbL6+d4P1ThhICccLo0tVa+DJ0f6fYl4mEw6cVUtuRB5OWaBE8P1sozZyegE= jones@jones-HP-ENVY-x360-Convertible-15-bq0xx"
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My server security group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["154.72.153.174/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    description      = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

}

resource "aws_instance" "my_server" {
  ami                    = "ami-09988af04120b3591"
  instance_type          = local.aws_instanceType
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered
  tags = {
    Name = "My-Server"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip

}
