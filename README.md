# Marketing email generator - LLM usage & lineage demo
## Overview
This repo provides an example LLM app to generate marketing emails to demonstrate how you can establish prompt lineage and response lineage around LLM usage. The following instructions should help you get started. It is intended to demonstration:
1. **How you can enable non-technical users (in this case, email marketing professionals) to use LLMs**
This app puts a user interface over some of Google Cloud's LLMs APIs for text generation that makes it easier for non-technical users to benefit from LLMs
2. **Provide some boundaries around how LLMs are used within your company while still leveraging the expertise of users**
This app has a narrowly defined use case: Generating marketing emails. This is accomplished by providing a place for user input that is part of the prompt while still providing structure around what the prompt will produce by telling it to write a marketing email. This provides some boundaries around the use case rather than giving users a "blank canvas" that allows them to generate content for an unsupported use case.
3. **Begin to implement "prompt & response lineage" by capturing the prompt and response (along with associated metadata) to a Pub/Sub topic**
This is a first step to implementing full lineage and governance for workloads that use LLMs. The Pub/Sub topics used in this app write to BigQuery, allowing you to analyze LLM usage over time.
4. **How Terraform can be used to support simplified infrastructure deployments**

**Note** \
Before you start: Though using a new GCP project for this example is not a requirement, it might be easiest to use a new GCP project for this. This makes cleanup much easier, as you can delete the whole project to ensure all assets are removed and it ensures no potential conflicts with existing resources. You can also remove resources by running `terraform destroy` after you deploy the resources

## Setup
### 0. Clone this repo in Cloud Shell
#### 1. You'll need to clone this repo locally first, then set the working directory to this folder using the following commands.
```
git clone https://github.com/shanecglass/llms-for-email-marketing.git
cd llms-for-email-marketing
```
#### 2. Enable the Cloud Resource Manager API
Check to make sure the [Cloud Resource Manager API](https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com) is enabled

### 1. Setup your infrastructure
This app uses Cloud Run, Cloud Build, BigQuery, and PubSub. Run the following to execute the Terraform script to setup everything.

#### 1. Intialize Terraform
First, initialize Terraform by running
```
terraform init
```

#### 2. Create the terraform.tfvars file and open it:
```
touch ./terraform.tfvars
nano ./terraform.tfvars
```

#### 3. Copy and paste the following code snippet. Edit the values for the required variables, save the file, and exit.

```
# This is an example of the terraform.tfvars file.
# The values in this file must match the variable types declared in variables.tf.
# The values in this file override any defaults in variables.tf.

# ID of the project in which you want to deploy the solution
project_id = "PROJECT_ID"

# Google Cloud region where you want to deploy the solution
# Example: us-central1
region = "REGION"

# Whether or not to enable underlying apis in this solution.
# Example: true
enable_apis = true

# Whether or not to protect BigQuery resources from deletion when solution is modified or changed.
# Example: false
force_destroy = false

# Whether or not to protect Cloud Storage resources from deletion when solution is modified or changed.
# Example: true
deletion_protection = true
```
#### 4. Verify that the Terraform configuration has no errors
Run the following:
```
terraform validate
```
If the command returns any errors, make the required corrections in the configuration and then run the terraform validate command again. Repeat this step until the command returns `Success! The configuration is valid.`

#### 5. Review resources
Review the resources that are defined in the configuration:
```
terraform plan
```

#### 6. Deploy the Terraform script

```
terraform apply
```

When you're prompted to perform the actions, enter `yes`. Terraform displays messages showing the progress of the deployment.

If the deployment can't be completed, Terraform displays the errors that caused the failure. Review the error messages and update the configuration to fix the errors. Then run `terraform apply` command again. For help with troubleshooting Terraform errors, see [Errors when deploying the solution using Terraform](https://cloud.google.com/architecture/big-data-analytics/analytics-lakehouse#tf-deploy-errors).

After all the resources are created, Terraform displays the following message:
```
Apply complete!
```

The Terraform output also lists the following additional information that you'll need:
- A link to the Dataform repository that was created
- The link to open the BigQuery editor for some sample queries

## Setup your analysis workspace
### 2. **Configure Dataform**
Create and initialize your Dataform workspace. Then copy and paste the [Dataform queries](./definitions) found in `prompt_cleaned.sqlx` and `response_cleaned.sqlx`, then start the workflow execution for all actions. These will incrementally clean and write the data to analysis-ready tables.

### 3. **Create your BQML model**
From the BigQuery console SQL Workspace, run the [`CREATE MODEL`](./create_kmeans_model.sql) to create the BQML model.

### 4. **Analyze your model!**
From here, you can get started analyzing the data and the results of the BQML model. Check out [this blog post](https://towardsdatascience.com/how-to-use-k-means-clustering-in-bigquery-ml-to-understand-and-describe-your-data-better-c972c6f5733b) to learn more about how you can get started with K-Means clustering in BQML
