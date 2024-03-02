###########################################################
#Author = Cloud Aseem
#Target = this main tf file to create a vpc, product subnet & EC2 instance & run the shell script to install tools 
###########################################################


resource "aws_vpc" "my_vpc_project1" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc_project1"
    }
} 

resource "aws_subnet" "product1" {
    vpc_id     = aws_vpc.my_vpc_project1.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"  # Specify the desired Availability Zone
    tags = {
        Name = "product1"
    }
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc_project1.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc_project1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.product1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "Project-sg10" {
    name        = "Project-sg10"
    description = "Allow TLS inbound traffic"
    vpc_id = aws_vpc.my_vpc_project1.id

    # Inbound Rules For SSH , HTTP, HTTPS, NODE.js, JENKINS , SONARQUBE .
    ingress = [
        for port in [22, 80, 443, 3000, 8080, 9000] : {    
            description      = "inbound rules"
            from_port        = port
            to_port          = port
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            security_groups  = []
            self             = false
        }
    ]

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Project10-sg"
    }
}

resource "aws_instance" "newproject" {
    ami                    = "ami-03f4878755434977f"   # change ami id for different region
    instance_type          = "t2.large" #change in your case with existing key
    key_name               = "test1245"
    subnet_id              = aws_subnet.product1.id
    availability_zone      = "ap-south-1a"  # Specify a different Availability Zone
    associate_public_ip_address = true  # Add this line to associate a public IP address    
    vpc_security_group_ids = [aws_security_group.Project-sg10.id]
    user_data              = templatefile("./deploy.sh", {})
    
    tags = {
        Name = "Nginx-Terraform-Jenkins-SonarQube-Docker-Trivy"
    }

    root_block_device {
        volume_size = 24
    }
}
