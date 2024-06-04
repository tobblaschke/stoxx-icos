```hcl
provider "google" {
  project = "index-icos-sandbox-e9ddv7"
  region  = "europe-west4"
  zone    = "europe-west4-a"
}

resource "google_compute_instance" "default" {
  name         = "vm-instance"
  machine_type = "e2-medium"

  labels = {
    environment = "sandbox"
    purpose     = "test"
  }

  tags = ["web-server"]

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      echo "Startup script executed"
      apt-get update
      EOT
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20 # Size in GB
    }
  }

  network_interface {
    network = "icostestnetwork"
    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
```

### Automating VM Shutdown using Cloud Functions and Cloud Scheduler We'll use a Cloud Function and a Cloud Scheduler job to shut down the VM every day at 7 PM CET.

#### Step 1: Create Cloud Function 1. **Create the Function Directory and Files** Create a directory for the function and the necessary files.

```bash
mkdir shutdown_vm_function
cd shutdown_vm_function
```

Create the `main.py` file:

```python
import os
from googleapiclient.discovery import build
from google.oauth2 import service_account

def shutdown_vm(event, context):
    project = os.environ.get('GCP_PROJECT')
    zone = os.environ.get('GCP_ZONE')
    instance = os.environ.get('GCP_INSTANCE')

    credentials = service_account.Credentials.from_service_account_file(
        'path-to-your-service-account-key.json')
    service = build('compute', 'v1', credentials=credentials)

    request = service.instances().stop(project=project, zone=zone, instance=instance)
    request.execute()

    print(f'Instance {instance} has been stopped.')
```

Create the `requirements.txt` file:

```text
google-api-python-client
google-auth
google-auth-httplib2
google-auth-oauthlib
```

2. **Deploy the Cloud Function**

```bash
gcloud functions deploy shutdown_vm_function \
    --runtime python39 \
    --trigger-topic shut-down-vm \
    --timeout 60s \
    --entry-point shutdown_vm \
    --set-env-vars GCP_PROJECT=index-icos-sandbox-e9ddv7,GCP_ZONE=europe-west4-a,GCP_INSTANCE=vm-instance
```

Replace `index-icos-sandbox-e9ddv7`, `europe-west4-a`, and `vm-instance` with your actual project ID, VM zone, and VM name.

#### Step 2: Create a Cloud Scheduler Job

Now, create a Cloud Scheduler job that will trigger the shutdown function every day at 7 PM CET.

```bash
gcloud scheduler jobs create pubsub shut-down-vm-job \
    --schedule="0 19 * * *" \
    --time-zone="Europe/Paris" \
    --topic=shut-down-vm \
    --message-body="Shutdown VM"
```