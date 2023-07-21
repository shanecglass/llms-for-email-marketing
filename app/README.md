## Marketing Email geneator
### Overview
This app provides a very basic tool that uses Large Language Models (LLMs) to generate marketing emails for the fictional company, Cymbal Retail. It is intended to demonstration:
1. **How you can enable non-technical users (in this case, email marketing professionals) to use LLMs**
This app puts a user interface over some of Google Cloud's LLMs APIs for text generation that makes it easier for non-technical users to benefit from LLMs
2. **Provide some boundaries around how LLMs are used within your company while still leveraging the expertise of users**
This app has a narrowly defined use case: Generating marketing emails. This is accomplished by providing a place for user input that is part of the prompt while still providing structure around what the prompt will produce by telling it to write a marketing email. This provides some boundaries around the use case rather than giving users a "blank canvas" that allows them to generate content for an unsupported use case.
3. **Begin to implement "prompt & response lineage" by capturing the prompt and response (along with associated metadata) to a Pub/Sub topic**
This is a first step to implementing full lineage and governance for workloads that use LLMs. The Pub/Sub topics used in this app write to BigQuery, allowing you to analyze LLM usage over time.


### Instructions to deploy to Cloud Run
Head to the Google Cloud Console and use [Cloud Shell](https://cloud.google.com/shell) to run the following steps. This can also be run in your local terminal if you have the [Cloud SDK installed and configured](https://cloud.google.com/sdk/docs/install)

0. Modify the `project_id` variable in the `modules.py` file:
Replace the value in line 11 of `modules.py` with your GCP project ID. You may also need to update the Pub/Sub topic IDs if you created topics with a different name
```
project_id = "building-on-bq-demos"
```

1. Make bld and deploy files executable
You may need to make the files executable:
```
chmod +x bld
chmod +x deploy
```

2. Build the container
Uses [Cloud Build](https://cloud.google.com/build) to build the container using the [bld](./bld) file
```
./bld
```

3. Deploy the container
Deploys the container to [Cloud Run](https://cloud.google.com/run)
```
./deploy
```

