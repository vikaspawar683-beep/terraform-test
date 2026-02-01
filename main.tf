resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "my-vpc"
  }
}

resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "igw-main"
  }
}

resource "aws_subnet" "public_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.main.id

  availability_zone = "ap-south-1a"
  tags = {
    "Name" = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.main.id
  availability_zone = "ap-south-1b"

  tags = {
    "Name" = "public-subnet-2"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }
}

resource "aws_route_table_association" "route-table-association-1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "route-table-association-2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow http trafic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow http trafic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}



resource "aws_instance" "main_1" {
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  ami           = "ami-019715e0d74f695be"
  associate_public_ip_address = true
  tags = {
    "Name" = "my-instance-1"
  }
  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install nginx -y
cat << HTML > /var/www/html/index.html
<h2>Hostname: $(hostname)</h2>
HTML
systemctl start nginx
systemctl enable nginx
EOF
}

resource "aws_instance" "main_2" {
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  ami           = "ami-019715e0d74f695be"
  associate_public_ip_address = true
  tags = {
    "Name" = "my-instance-2"
  }
  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install nginx -y
cat << HTML > /var/www/html/index.html
<h2>Hostname: $(hostname)</h2>
HTML
systemctl start nginx
systemctl enable nginx
EOF
}

resource "aws_lb" "alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  internal           = false

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  security_groups = [aws_security_group.alb_sg.id]
}


resource "aws_lb_target_group" "alb-tg" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id  = aws_vpc.main.id

  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = aws_instance.main_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = aws_instance.main_2.id
  port             = 80
}




resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}
