.PHONY: get-google build build-from-scratch run-i run-d exec clean

# Default values for variables
GOOGLE_REPO  ?= us-docker.pkg.dev/qwiklabs-resources/healthcare-qwiklabs-resources/
GOOGLE_NAME  ?= dataflow-pipeline
GOOGLE_TAG   ?= v0.02

LOCAL_REPO ?= mgkahn/
LOCAL_NAME ?= capsuletech
LOCAL_TAG ?= ${GOOGLE_TAG}

get-google:
	gcloud auth configure-docker us-docker.pkg.dev
	docker pull $(GOOGLE_REPO)$(GOOGLE_NAME):$(GOOGLE_TAG)

build:
	docker build --tag ${LOCAL_REPO}${LOCAL_NAME}:${LOCAL_TAG} .

build-from-scratch:
	docker build --no-cache --tag ${LOCAL_REPO}${LOCAL_NAME}:${LOCAL_TAG} .

run-i:
	docker run -it --rm --name capsuletech --entrypoint /bin/bash ${LOCAL_REPO}${LOCAL_NAME}:${LOCAL_TAG}

run-d:
	docker run -d --rm --name capsuletech --entrypoint ./entrypoint2.sh ${LOCAL_REPO}${LOCAL_NAME}:${LOCAL_TAG}

exec:
	docker exec -it capsuletech /bin/bash


clean:
	docker image prune -f
