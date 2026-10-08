# Ejemplo mínimo de Terraform: una máquina virtual en Google Cloud.
#
#   terraform init      # descarga el provider de Google
#   terraform plan      # muestra lo que se va a crear
#   terraform apply     # lo crea
#   terraform destroy   # lo borra

# PROVIDER: con qué nube hablamos y dónde trabajamos.
# Las credenciales salen de "gcloud auth application-default login".
provider "google" {
  project = "mi-proyecto" # <- cambia por el ID de tu proyecto
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

# RESOURCE: qué queremos que exista. Tipo "google_compute_instance", nombre local "vm".
resource "google_compute_instance" "vm" {
  name         = "vm-terraform"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    network = "default"
    access_config {} # IP pública
  }
}
