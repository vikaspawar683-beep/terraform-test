variable"instance_type"{
  type  =string
  description="EC2 instance type for the web server"
  default  ="t2.micro"
}

variable"ami"{
  type  =string
  description="ami-019715e0d74f695be" #copy your instance ami id
}
  
