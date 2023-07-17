# This file will get executed when the function is executed
import json
import vertexai

from concurrent import futures
from google.cloud import pubsub_v1
# from google.cloud import secretmanager
from typing import Callable
from google.cloud import aiplatform_v1 as aiplatform
from vertexai.preview.language_models import TextGenerationModel, TextEmbeddingModel

project = "building-on-bq-demos"
location = "us-central1"
pubsub_topic_id = "email_marketing_llm"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project, pubsub_topic_id)

vertexai.init(project=project,
  location=location)

def get_text_embeddings(input):
  model = TextEmbeddingModel.from_pretrained("textembedding-gecko@001")
  try:
    embeddings = model.get_embeddings([input])
    output = [embedding.values for embedding in embeddings]
    return output
  except Exception:
    return [None for _ in range(len(input))]

def get_response(input_prompt):
  model = TextGenerationModel.from_pretrained("text-bison@001")
  parameters = {
    "temperature": 0.9,  # Temperature controls the degree of randomness in token selection.
    "max_output_tokens": 512,  # Token limit determines the maximum amount of text output.
    "top_p": 0.8,  # Tokens are selected from most probable to least until the sum of their probabilities equals the top_p value.
    "top_k": 40,  # A top_k of 1 means the selected token is the most probable among all tokens.
  }

  output = model.predict(
    prompt=input_prompt,
    **parameters
  )
  print(output.text)
  return output

def publish_pubsub(text, embedding):
  #"""Text embedding with a Large Language Model."""
      data_string = json.dumps(f"{text},{embedding}")
    # Data must be a bytestring
      data = data_string.encode("utf-8")
    # When you publish a message, the client returns a future.
      future = publisher.publish(topic_path, data)
      print(future.result())
