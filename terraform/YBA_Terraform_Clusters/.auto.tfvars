###### Global #########
project_id         = "project-7b6bf38a-3ad2-4d2b-bdb"
network_project_id = "default"
region             = "northamerica-northeast1"
// kms_key_self_link  = "projects/project-7b6bf38a-3ad2-4d2b-bdb/locations/us-central1/keyRings/global-key-ring-en/cryptoKeys/global-kms-key-en"


kubernetes_clusters_project = {
    "kubernetes" = {
    enable_external_ip                 = false
    enable_shielded_vm                 = true
    machine_name                       = "kubernetes"
    instance_count                     = 2
    attached_disks_per_instance        = 1
    enable_yugabyte_disk               = false   ## boot disk
    enable_data1_disk                  = false
    enable_shared_disk                 = false
    enable_wal1_disk                   = false
    enable_boot_disk_snapshot_attach   = true
    enable_yugabyte_disk_snapshot_attach = false
    enable_data1_disk_snapshot_attach  = false
    enable_wal1_disk_snapshot_attach   = false
    enable_shared_disk_snapshot_attach = false
    attached_persistent_disk_sizes     = []
    machine_zone                       = ["northamerica-northeast1-a","northamerica-northeast1-b","northamerica-northeast1-c"]
    policy_name                        = "ansible-snapshot-policy-monitor"
    utc_time                           = "00:00"
    retention_days                     = 7
    storage_locations                  = "us"
    enable_boot_disk                   = true
    boot_disk_size                     = 20
    boot_disk_type                     = "pd-balanced"
    instance_with_bootdisk_snapshot    = false
    snapshot_selflink                  = null
    instance_image_selflink            = "projects/rhel-cloud/global/images/rhel-10-0-eus-v20260310"
    # kms_key_self_link                  = null
    labels                             = {}
    internal_ip = [
  "10.0.0.17",
  "10.0.0.18"
]
    region                             = "northamerica-northeast1"
    machine_type                       = "e2-small"
    vm_deletion_protection             = false
    network_tags                       = ["yugabyte","allow-ssh"]
    network                            = "vpc-yugabyte-terraform-cluster"
    subnetwork                         = "yugabyte-sub-1"
    service_account = {
      email  = "yugabyte@project-7b6bf38a-3ad2-4d2b-bdb.iam.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }
    metadata = {}
    local_disk_count = 0
    shielded_instance_config = {
      enable_secure_boot          = true
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    }
  }
}

kubernetes_clusters_project_config = {
  "ansible-master-node" = {
    enable_external_ip                 = false
    enable_shielded_vm                 = true
    machine_name                       = "ansible-master-node"
    instance_count                     = 1
    attached_disks_per_instance        = 1
    enable_yugabyte_disk               = false   ## boot disk
    enable_data1_disk                  = false
    enable_shared_disk                 = false
    enable_wal1_disk                   = false
    enable_boot_disk_snapshot_attach   = true
    enable_yugabyte_disk_snapshot_attach = false
    enable_data1_disk_snapshot_attach  = false
    enable_wal1_disk_snapshot_attach   = false
    enable_shared_disk_snapshot_attach = false
    attached_persistent_disk_sizes     = []
    machine_zone                       = ["northamerica-northeast1-a","northamerica-northeast1-b","northamerica-northeast1-c"]
    policy_name                        = "ansible-snapshot-policy-monitor"
    utc_time                           = "00:00"
    retention_days                     = 7
    storage_locations                  = "us"
    enable_boot_disk                   = true
    boot_disk_size                     = 20
    boot_disk_type                     = "pd-balanced"
    instance_with_bootdisk_snapshot    = false
    snapshot_selflink                  = null
    instance_image_selflink            = "projects/rhel-cloud/global/images/rhel-10-0-eus-v20260310"
    # kms_key_self_link                  = null
    labels                             = {}
    internal_ip = [
  "10.0.0.16",
]
    region                             = "northamerica-northeast1"
    machine_type                       = "e2-small"
    vm_deletion_protection             = false
    network_tags                       = ["yugabyte","allow-ssh"]
    network                            = "vpc-yugabyte-terraform-cluster"
    subnetwork                         = "yugabyte-sub-1"
    service_account = {
      email  = "yugabyte@project-7b6bf38a-3ad2-4d2b-bdb.iam.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }
    metadata = {}
    local_disk_count = 0
    shielded_instance_config = {
      enable_secure_boot          = true
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    }
  }
}


