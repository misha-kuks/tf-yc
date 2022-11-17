terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone = "ru-central1-a"
  token = var.yc_token
}

resource "yandex_compute_instance" "vm-1" {
  name = "vm-1"
  resources {
    cores = 2
    memory = 4
  }

boot_disk {
  initialize_params {
    image_id = "fd8ch5n0oe99ktf1tu8r"
  }
}

network_interface {
  subnet_id = yandex_vpc_subnet.subnet-1.id
  nat = true
}  

metadata = {
  ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}

connection {
user = "ubuntu"
private_key = file("~/.ssh/id_rsa")
host = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
provisioner "remote-exec" {
inline = [
"sudo apt update && sudo apt install -y nginx",
]
}

}



resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name = "subnet1"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.79.0/24"]
}

output "internal_ip_address_vm-1" {
  description = "Internal IP address"
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm-1" {
description = "External IP address"
value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "link_to_web_server" {
description = "URL of Web Server"
value = "http://${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"
}
