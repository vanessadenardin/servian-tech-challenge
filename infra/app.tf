resource "aws_ecs_cluster" "app" {
  name = "${var.prefix}-app"
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = var.container_image
      essential    = true
      cpu          = 128
      memory       = 256
      command      = ["serve"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
            awslogs-region        = "ap-southeast-2"
            awslogs-group         = aws_cloudwatch_log_group.default.name
            awslogs-stream-prefix = "app"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name = "VTT_DBHOST"
          value = aws_rds_cluster.postgres.endpoint
        },
        {
          name = "VTT_DBPASSWORD"
          value = var.postgresql_password
        },
        {
          name = "VTT_LISTENHOST"
          value = "0.0.0.0"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 3000
  }

  network_configuration {
    subnets          = data.aws_subnets.available.ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = var.production ? false : true
  }
}

resource "aws_lb" "app" {
  name               = "${var.prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.available.ids

  enable_deletion_protection = var.production ? true : false
}

resource "aws_lb_target_group" "app" {
  name     = "${var.prefix}-tg"
  port     = 3000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id 

  health_check {
    path = "/healthcheck"
  }
}

resource "aws_lb_listener" "app_80" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "app_443" {
  count             = var.certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.prefix}-lb-sg"
  description = "Allow connections from internet"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "port 80 from internet"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "port 443 from internet"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "allowing healthcheck access"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.selected.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "${var.prefix}-lb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.prefix}-server"
  description = "Allow connections from the load balancer"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "port 3000 from load balancer"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.lb_sg.id]
      self             = false
    }
  ]

  egress = [
    {
      description      = "allowing internet access"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "${var.prefix}-server"
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.prefix}"
  retention_in_days = 7
}

resource "aws_route53_record" "app" {
  count   = var.domain_name == "" ? 0 : 1
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.prefix
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.app.dns_name]
}
