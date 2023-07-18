CREATE OR REPLACE MODEL`email_marketing_llm_usage.prompt_clusters`
OPTIONS(
  model_type='kmeans',
  KMEANS_INIT_METHOD = "kmeans++",
  num_clusters=3,
  standardize_features = TRUE) AS
SELECT
  TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), publish_time, HOUR) AS hours_since_prompt,
  prompt_embedding
FROM
  `email_marketing_llm_usage.prompt_cleaned`
