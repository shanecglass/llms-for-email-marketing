PROJ=${PROJ}
REGION=${REGION}
DOCKER_PATH=${DOCKER_PATH}
gcloud builds submit --tag "gcr.io/$PROJ/email-marketing-llm"
