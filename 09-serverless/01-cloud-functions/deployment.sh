#!/usr/bin/env bash
NOMBRE_FUNCION=urandom-generator
REGION=europe-west1
gcloud functions deploy $NOMBRE_FUNCION \
        --entry-point=get_urandom \
        --region $REGION \
        --runtime python313 \
        --trigger-http \
        --memory 128Mi \
        --timeout 60s \
        --allow-unauthenticated

