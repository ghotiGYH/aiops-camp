# Configure the TencentCloud Provider
provider "tencentcloud" {
  region     = var.regoin
  secret_id  = var.secret_id
  secret_key = var.secret_key
}

# Get availability zones
data "tencentcloud_availability_zones_by_product" "default" {
  product = "cvm"
}

# Get availability images
data "tencentcloud_images" "default" {
  image_type = ["PUBLIC_IMAGE"]
  os_name    = "ubuntu"
}

# Get availability instance types
data "tencentcloud_instance_types" "default" {
  # 机型族
  filter {
    name   = "instance-family"
    values = ["S5"]
  }

  cpu_core_count = 2
  memory_size    = 2
  exclude_sold_out = true
}

resource "tencentcloud_instance" "cvm-docker" {
  depends_on                 = [tencentcloud_security_group_lite_rule.default]
  count                      = 1
  instance_name              = "cvm-docker"
  availability_zone          = data.tencentcloud_availability_zones_by_product.default.zones.0.name
  image_id                   = data.tencentcloud_images.default.images.0.image_id
  instance_type              = data.tencentcloud_instance_types.default.instance_types.0.instance_type
  system_disk_type           = "CLOUD_BSSD"
  system_disk_size           = 50
  allocate_public_ip         = true
  internet_max_bandwidth_out = 100
  instance_charge_type       = "SPOTPAID"
  orderly_security_groups    = [tencentcloud_security_group.default.id]
  password                   = var.password
  user_data                  = filebase64("./install_docker.sh")
}

# Create security group
resource "tencentcloud_security_group" "default" {
  name        = "tf-security-group"
  description = "make it accessible for both production and stage ports"
}

# Create security group rule allow ssh request
resource "tencentcloud_security_group_lite_rule" "default" {
  security_group_id = tencentcloud_security_group.default.id
  ingress = [
    "ACCEPT#0.0.0.0/0#22#TCP",
    "ACCEPT#0.0.0.0/0#6443#TCP",
  ]

  egress = [
    "ACCEPT#0.0.0.0/0#ALL#ALL"
  ]
}

#resource "null_resource" "install_docker" {
#  provisioner "remote-exec" {
#    connection {
#      type     = "ssh"
#      host     = tencentcloud_instance.cvm-docker[0].public_ip
#      user     = "ubuntu"
#      password = var.password
#    }
#
#    inline = [
#      "sudo apt-get update",
#      "sudo apt-get install -y ca-certificates curl",
#      "sudo install -m 0755 -d /etc/apt/keyrings",
#      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
#      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
#      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
#      "sudo apt-get update",
#      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
#    ]
#  }
#  depends_on = [tencentcloud_instance.cvm-docker]
#}
