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

module "pubsub" {
  source              = "terraform-google-modules/pubsub/google"
  version             = "~> 5.0"

  for_each            = toset(var.resource_purpose)
  topic               = "email_marketing_app_demo_llm_${each.key}"
  project_id          = module.project-services.project_id

  bigquery_subscriptions = [
    {
      name                = "write-to-bq-${each.key}"
      table               = "${module.project-services.project_id}.${google_bigquery_dataset.dest_dataset.dataset_id}.${each.key}"
      use_topic_schema    = true
      write_metadata      = true

    }
  ]

  depends_on = [
    google_bigquery_table.dest_tables
  ]
}
