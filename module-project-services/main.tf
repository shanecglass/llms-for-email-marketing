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

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "14.2.1"
  disable_services_on_destroy = false

  project_id  = var.project_id
  enable_apis = var.enable_apis

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
    "workflows.googleapis.com",
  ]
  activate_api_identities = [{
    api = "aiplatform.googleapis.com"
    roles = [
      "roles/aiplatform.user",                  // Needs to predict from endpoints
      "roles/aiplatform.serviceAgent",          // Service account role
      ]
    },
    {
      api = "bigquery.googleapis.com"
      roles = [
        "roles/bigquery.dataOwner",             // Needs to create datasets, create tables, update tables, set IAM policy
        "roles/bigquery.jobUser",               // Needs to create and run jobs, create models
      ]
    },
    {
      api = "cloudbuild.googleapis.com"
      roles = [
        "roles/cloudbuild.builds.editor",       // Needs to create and update builds, list projects, and delete builds
        "roles/cloudbuild.builds.builder",      // Service account role
      ]
    },
    {
      api = "cloudrun.googleapis.com"
      roles = [
        "roles/run.admin",                      //Needs to deploy, invoke, and set IAM policy
        "roles/run.invoker",                    //Service account role
      ]
    },
    {
      api = "dataform.googleapis.com"
      roles = [
        "roles/dataform.admin",                 //Needs to create repos; create, commit, and invoke workspaces; Set IAM policy for workspaces and repos; Pull files; Invoke workflows
      ]
    },
    {
      api = "logging.googleapis.com"
      roles = [
        "roles/logging.logWriter",              //Needs to write log entries
      ]
    },
    {
      api = "pubsub.googleapis.com"
      roles = [
        "roles/pubsub.editor",                  //Needs to create and modify topics/subscriptions, publish and consume messages
        "roles/pubsub.publisher",               // Cloud Run invoker needs to publish Pub/Sub messages to topic
      ]
    },
    {
      api = "workflows.googleapis.com"
      roles = [
        "roles/workflows.editor",                //Needs to create and invoke workflows
      ]
    },
  ]
}
