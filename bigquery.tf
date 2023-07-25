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

resource "google_bigquery_dataset" "dest_dataset" {
  project             = module.project-services.project_id
  dataset_id          = var.bq_dataset
  location            = var.region
  depends_on = [ module.project-services]
}

resource "google_bigquery_table" "dest_tables" {
  for_each            = toset(var.resource_purpose)
  project             = module.project-services.project_id
  dataset_id          = google_bigquery_dataset.dest_dataset.dataset_id
  table_id            = each.key
  deletion_protection = false

  time_partitioning {
    field             = "publish_time"
    type              = "HOUR"
  }

  schema = <<EOF
[
  {
    "mode": "NULLABLE",
    "name": "data",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "subscription_name",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "message_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "publish_time",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "attributes",
    "type": "STRING"
  }
]
EOF

  depends_on = [google_bigquery_dataset.dest_dataset]
}

resource "google_bigquery_job" "load_samples_prompts" {
  job_id = "job_load_samples"
  labels = {
    "my_job" ="load"
  }

  load {
    source_uris = ["${var.sample_data_bucket}prompts.parquet"]
    destination_table {
      project_id = module.project-services.project_id
      dataset_id = google_bigquery_dataset.dest_dataset.dataset_id
      table_id   = "prompts"
    }
    write_disposition     = "WRITE_EMPTY"
    source_format         = "PARQUET"
    autodetect            = false
    }
  }

resource "google_bigquery_job" "load_samples_responses" {
  job_id = "job_load_samples"
  labels = {
    "my_job" ="load"
  }

  load {
    source_uris = ["${var.sample_data_bucket}responses.parquet"]
    destination_table {
      project_id = module.project-services.project_id
      dataset_id = google_bigquery_dataset.dest_dataset.dataset_id
      table_id   = "responses"
    }
    write_disposition     = "WRITE_EMPTY"
    source_format         = "PARQUET"
    autodetect            = false
    }

    depends_on = [google_bigquery_dataset.dest_dataset, google_bigquery_table.dest_tables]
  }

resource "google_dataform_repository" "cleaning_repo" {
  provider = google-beta
  name = "LLM-Cleaning-Email-Marketing-Demo"
  region = var.region
  project = module.project-services.project_id

  workspace_compilation_overrides {
    default_database = module.project-services.project_id
  }
}

resource "google_bigquery_table" "cleaned_prompts" {
  project             = module.project-services.project_id
  dataset_id          = google_bigquery_dataset.dest_dataset.dataset_id
  table_id            = "prompt_cleaned"
  deletion_protection = false

  time_partitioning {
    field             = "publish_time"
    type              = "HOUR"
  }

  schema = <<EOF
  [
    {
      "description": "Original JSON ingested from Pub/Sub",
      "name": "original_message",
      "type": "JSON"
    },
    {
      "description": "The timestamp of when the Pub/Sub message was published. This is roughly equivalent to when the user submitted their request",
      "name": "publish_time",
      "type": "TIMESTAMP"
    },
    {
      "description": "A unique identifier for each of the user's sessions",
      "name": "session_id",
      "type": "STRING"
    },
    {
      "description": "The full text of the prompt that was generated from user input",
      "name": "prompt",
      "type": "STRING"
    },
    {
      "description": "The Pub/Sub message ID",
      "name": "message_id",
      "type": "STRING"
    },
    {
      "description": "Name of the Pub/Sub subscription that wrote the data to BigQuery",
      "name": "subscription_name",
      "type": "STRING"
    },
    {
      "description": "Pub/Sub message attributes",
      "name": "attributes",
      "type": "STRING"
    },
    {
      "description": "STRING representation of the array of the text embeddings computed for the prompt using the Vertex AI Gecko text embedding model",
      "name": "prompt_embedding",
      "type": "STRING"
    },
    {
      "description": "Array representation of the text embeddings computed for the prompt using the Vertex AI Gecko text embedding model",
      "mode": "REPEATED",
      "name": "prompt_embedding_values",
      "type": "NUMERIC"
    }
  ]
  EOF
}

resource "google_bigquery_table" "cleaned_responses" {
  project             = module.project-services.project_id
  dataset_id          = google_bigquery_dataset.dest_dataset.dataset_id
  table_id            = "response_cleaned"
  deletion_protection = false

  time_partitioning {
    field             = "publish_time"
    type              = "HOUR"
  }

  schema = <<EOF
  [
    {
      "description": "Original JSON ingested from Pub/Sub",
      "name": "original_message",
      "type": "JSON"
    },
    {
      "description": "The timestamp of when the Pub/Sub message was published. This is roughly equivalent to when the user submitted their request",
      "name": "publish_time",
      "type": "TIMESTAMP"
    },
    {
      "description": "A unique identifier for each of the user's sessions",
      "name": "session_id",
      "type": "STRING"
    },
    {
      "description": "The full text of the response that was generated from user input",
      "name": "response",
      "type": "STRING"
    },
    {
      "description": "Safety attributes associated with the response as determined by the model",
      "name": "safety_attributes",
      "type": "JSON"
    },
    {
      "description": "The Pub/Sub message ID",
      "name": "message_id",
      "type": "STRING"
    },
    {
      "description": "Name of the Pub/Sub subscription that wrote the data to BigQuery",
      "name": "subscription_name",
      "type": "STRING"
    },
    {
      "description": "Pub/Sub message attributes",
      "name": "attributes",
      "type": "STRING"
    },
    {
      "description": "STRING representation of the array of the text embeddings computed for the response using the Vertex AI Gecko text embedding model",
      "name": "response_embedding",
      "type": "STRING"
    },
    {
      "mode": "REPEATED",
      "name": "response_embeddingg_values",
      "type": "NUMERIC"
    }
  ]
  EOF
}
