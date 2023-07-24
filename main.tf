/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 14.2"
  project_id                  = var.project_id
  enable_apis                 = var.enable_apis
  activate_apis = [
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudrun.googleapis.com",
    "config.googleapis.com",
    "dataform.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "workflows.googleapis.com",
  ]
}

resource "time_sleep" "wait_after_apis_activate" {
  depends_on      = [module.project-services]
  create_duration = "60s"
}

resource "google_project_service_identity" "cloud_run" {
  provider = google-beta
  project  = module.project-services.project_id
  service  = "cloudrun.googleapis.com"

  depends_on = [time_sleep.wait_after_apis_activate]
}

resource "google_service_account" "cloud_run_invoke" {
  project      = module.project-services.project_id
  account_id   = "demo-app"
  display_name = "Cloud Run Auth Service Account"
}

resource "google_project_iam_member" "cloud_run_invoke_roles" {
  for_each = toset([
    "roles/pubsub.publisher",               // Needs to publish Pub/Sub messages to topic
    "roles/run.invoker",                    // Service account role to manage access to app
    "roles/aiplatform.user",                // Needs to predict from endpoints
    "roles/aiplatform.serviceAgent",        // Service account role
    ]
  )

  project = module.project-services.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_run_invoke.email}"

  depends_on = [
    google_service_account.cloud_run_invoke
  ]
}

resource "time_sleep" "wait_after_all_resources" {
  create_duration = "120s"
  depends_on = [
    module.project-services,
    google_project_iam_member.cloud_run_invoke_roles,
    google_bigquery_dataset.dest_dataset,
    google_bigquery_table.dest_tables,
    google_bigquery_job.load_samples_prompts,
    google_bigquery_job.load_samples_responses,
    google_dataform_repository.cleaning_repo,
    google_bigquery_table.cleaned_prompts,
    google_bigquery_table.cleaned_responses,
    module.pubsub,

  ]
}
