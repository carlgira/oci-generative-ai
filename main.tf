# Create datasource of images from the image list
data "oci_core_images" "images" {
  compartment_id = var.compartment_ocid
  operating_system = "Canonical Ubuntu"
  filter {
    name = "display_name"
    values = ["^Canonical-Ubuntu-22.04-([\\.0-9-]+)$"]
    regex = true
  }
}

# Create a compute instance with a public IP address using oci provider
resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  shape               = var.instance_shape

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.images.images[0].id
  }

  create_vnic_details {
    assign_public_ip = "true"
    subnet_id        = oci_core_subnet.subnet.id
  }
  # Add private key
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("setup-instance.sh"))
  }
}

# Create datasource for availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.compartment_ocid
}

# Create internet gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.generative_ai_vcn.id
  display_name   = "generative-ai-internet-gateway"
}

# Create route table
resource "oci_core_route_table" "generative_ai_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.generative_ai_vcn.id
  display_name   = "generative-ai-route-table"
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create security list with ingress and egress rules
resource "oci_core_security_list" "generative_ai_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.generative_ai_vcn.id
  display_name   = "generative-ai-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "0.0.0.0/0"
    description = "Allow all inbound traffic"
  }

  # ingress rule for ssh
    ingress_security_rules {
        protocol    = "6" # tcp
        source      = "0.0.0.0/0"
        description = "Allow ssh"
        tcp_options {
            max = 22
            min = 22
        }
    }
}

# Create a subnet
resource "oci_core_subnet" "subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  display_name      = "generative-ai-subnet"
  vcn_id            = oci_core_virtual_network.generative_ai_vcn.id
  route_table_id    = oci_core_route_table.generative_ai_route_table.id
  security_list_ids = ["${oci_core_security_list.generative_ai_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.generative_ai_vcn.default_dhcp_options_id
}

# Create a virtual network
resource "oci_core_virtual_network" "generative_ai_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "generative-ai-vcn"
}

output "instance_public_ip" {
  value = <<EOF
  
  Wait 20 minutes for the instance to be ready.
  Then, you can connect to the instance using the following command:

  ssh tunnel => 
    ssh -i server.key -L 7860:localhost:7860 -L 5000:localhost:5000 ubuntu@${oci_core_instance.instance.public_ip}

  stable diffusion => http://localhost:7860
  
  bloom => http://localhost:5000

EOF
}