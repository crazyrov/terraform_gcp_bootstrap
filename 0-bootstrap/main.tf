# Copyright 2021 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.
provider "google" {
  version = "~> 3.53"
}

provider "google-beta" {
  version = "~> 3.53"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

/*************************************************
  Bootstrap GCP Organization.
*************************************************/

resource "google_folder" "bootstrap" {
  display_name = "bootstrap-1"
  parent       = "organizations/${var.org_id}"
}

module "seed_bootstrap" {
  source                         = "terraform-google-modules/bootstrap/google"
  version                        = "~> 2.0"
  project_prefix                 = var.project_prefix
  org_id                         = var.org_id
  folder_id                      = google_folder.bootstrap.id
  billing_account                = var.billing_account
  group_org_admins               = var.group_org_admins
  group_billing_admins           = var.group_billing_admins
  default_region                 = var.default_region
  org_project_creators           = var.org_project_creators
  sa_enable_impersonation        = true
  org_admins_org_iam_permissions = ["roles/orgpolicy.policyAdmin", "roles/resourcemanager.organizationAdmin", "roles/billing.user"]

  project_labels = {
    application     = "env-bootstrap"
    owner           = "tamara_seifman_at_edg_com_au"
    business        = "danmurphys"
    managedby       = "edg_digital_support"
    support_contact = "edgdigitalsupport_edg_com_au"
    environment     = "bootstrap"
    costcentre      = "ss6087"
    project_code    = "bootstrap"
    projectendmonth = "april-2021"
    components      = "bootstrap"
  }

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securitycenter.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  sa_org_iam_permissions = [
    "roles/accesscontextmanager.policyAdmin",
    "roles/billing.user",
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.folderAdmin",
    "roles/securitycenter.notificationConfigEditor",
    "roles/resourcemanager.organizationViewer"
  ]
}

resource "google_billing_account_iam_member" "tf_billing_admin" {
  billing_account_id = var.billing_account
  role               = "roles/billing.admin"
  member             = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
}

