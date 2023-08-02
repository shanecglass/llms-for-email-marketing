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

# --------------------------------------------------
# VARIABLES
# Set these before applying the configuration
# --------------------------------------------------

#Update with your project ID
variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

#Update with your preferred region. Please consider the carbon footprint of your workload when choosing a region: https://cloud.google.com/sustainability/region-carbon#data
variable "region" {
  type        = string
  description = "Google Cloud Region"
  default     = "us-central1"
}


variable "bq_dataset" {
  type        = string
  description = "BigQuery dataset ID"
  default = "email_marketing_llm_usage"
}

variable "resource_purpose" {
  type        = set(string)
  description = "The purpose of the PubSub topics and subscriptions used to define resource ID"
  default = ["prompts", "responses"]
}

variable "sample_data_bucket" {
  type = string
  description = "Name of the GCS bucket that holds the sample data"
  default = "gs://llm-email-marketing-app-demo-data/"
}

variable "labels" {
  type        = map(string)
  description = "A map of labels to apply to contained resources."
  default     = { "llm-email-marketing-app-demo" = true }
}

variable "enable_apis" {
  type        = string
  description = "Whether or not to enable underlying apis in this solution. ."
  default     = true
}

variable "force_destroy" {
  type        = string
  description = "Whether or not to protect BigQuery resources from deletion when solution is modified or changed."
  default     = false
}

variable "use_case_short" {
  type        = string
  description = "Short name for use case"
  default     = "llm-email-marketing-app-demo"
}

variable "public_data_bucket" {
  type        = string
  description = "Public Data bucket for access"
  default     = "data-analytics-demos"
}
