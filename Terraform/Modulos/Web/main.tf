#=================================#
# GRUPO DE SEGURIDAD TRANSPARENTE #
#=================================#
resource "aws_security_group" "sg_web" {
    name = "SG-Web"
    description = "Permite trafico interno desde la VPC"
    vpc_id = var.vpc_id

    # Entrada: Permitimos todo
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.rango_vpc] 
    }
    # Salida: Permitimos todo
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "SG-Web" }
}

#=============================#
# BALANCEADOR DE CARGAS (ALB) #
#=============================#
resource "aws_alb" "balanceador_web" {
    name = "ALB-Web-Interno"
    internal = true 
    load_balancer_type = "application"
    security_groups = [aws_security_group.sg_web.id]
    subnets = [var.subred_web_id, var.subred_alb_respaldo_id]
}

resource "aws_alb_target_group" "tg_web" {
    name = "TG-Servidores-Web"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
}

resource "aws_alb_listener" "puerta_enlace_alb" {
    load_balancer_arn = aws_alb.balanceador_web.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.tg_web.arn
    }
}

#========================#
# PLANTILLA DE CLONACIÓN #
#========================#
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

resource "aws_launch_template" "plantilla_web" {
    name_prefix = "Plantilla-Apache"
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t3.small"
    key_name = var.clave_ssh
    vpc_security_group_ids = [aws_security_group.sg_web.id]

#===================================#
# Configuración Autónoma de Ansible #
#===================================#
user_data = base64encode(<<-EOF
            #!/bin/bash

            echo "Esperando a que el Firewall otorgue acceso a Internet HTTP/HTTPS..."

            while ! curl -s -m 2 https://www.google.com > /dev/null; do
                echo "Aún no hay conexión... Reintentando en 5 segundos."
                sleep 5
            done

            echo "¡Conexión a Internet establecida! Iniciando instalación..."

            # 1. Instalamos Ansible y Git
            apt-get update
            apt-get install -y software-properties-common
            add-apt-repository --yes --update ppa:ansible/ansible
            apt-get install -y ansible git

            # 2. Clonamos el repositorio de GitHub
            git clone https://github.com/ByAnder123/Proyecto-ASIR-IaC /tmp/mi_proyecto

            # 3. Entramos en la carpeta y ejecutamos el playbook web localmente
            cd /tmp/mi_proyecto/Ansible/Roles/Web/Tasks
            ansible-playbook main.yml
            EOF
)

    tag_specifications {
        resource_type = "instance"
        tags = { Name = "VM-Clon-Web" }
    }
}

#=============================#
# GRUPO DE AUTOESCALADO (ASG) #
#=============================#
resource "aws_autoscaling_group" "asg_web" {
    name = "ASG-Cluster-Web"
    vpc_zone_identifier = [var.subred_web_id]
    target_group_arns = [aws_alb_target_group.tg_web.arn] 
    
    min_size = 1
    max_size = 5
    desired_capacity = 1

    launch_template {
        id = aws_launch_template.plantilla_web.id
        version = "$Latest"
    }
}

resource "aws_autoscaling_policy" "escalado_inteligente" {
    name = "CPU_70"
    autoscaling_group_name = aws_autoscaling_group.asg_web.name
    policy_type = "TargetTrackingScaling"

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70.0
    }
}