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

#URL of the Dataform repository used to clean raw prompt/response data
output "dataform_repo_url" {
  value       = "https://console.cloud.google.com/bigquery/dataform/locations/us-central1/repositories/LLM-Cleaning-Email-Marketing/details/workspaces?project=${var.project_id}"
  description = "The URL to launch the Dataform UI for the repo created"
}

#URL of the BigQuery editor for this project
output "bigquery_editor_url" {
  value       = "https://console.cloud.google.com/bigquery?project=${var.project_id}"
  description = "The URL to launch the BigQuery editor"
}
