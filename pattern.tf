terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "AgAAAABRl1XhAATuwYX5S9lFNkmml4SmcfTlwh8"
  cloud_id  = "b1gaukp5b6t786s5v82q"
  folder_id = "b1g8vakc2uotg05v3orc"
  zone      = "ru-central1-c"
}

resource "yandex_compute_instance" "vm" {
  count = 2  

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81d2d9ifd50gmvc03g"
      size = 13
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  
  tags = {
    Name = "vm_pattern_${count.index}"
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  for_each = yandex_compute_instance.vm
  value = each.network_interface.0.nat_ip_address
}