GCP_ARTIFACT_PREFIX := us-west1-docker.pkg.dev
GCP_ARTIFACT_REPO := $(GCP_PROJECT)-repo
GCP_TAG_PREFIX := $(GCP_ARTIFACT_PREFIX)/$(GCP_PROJECT)/$(GCP_ARTIFACT_REPO)
GCP_BACKEND_NAME := $(GCP_PROJECT)-app
GCP_FRONTEND_NAME := $(GCP_PROJECT)-frontend
TAG := latest
LOCAL_BUILD=$(GCP_FRONTEND_NAME):$(COMMIT_SHA)
BACKEND_TAG=$(GCP_TAG_PREFIX)/$(GCP_BACKEND_NAME):$(TAG)
FRONTEND_TAG=$(GCP_TAG_PREFIX)/$(GCP_FRONTEND_NAME):$(TAG)
COMMIT_SHA := $(shell git rev-parse --short HEAD)
BREW_PREFIX := $(shell brew --prefix)

# Targets
.PHONY: all check-env setup install login build ci run clean fresh local deploy help

# Default target: run all tasks
all: clean install deploy ## Run all tasks (clean, lint, test, build, deploy)

check-env: ## Check environment variables
	@if [ -z "$(GOOGLE_APPLICATION_CREDENTIALS)" ]; then echo "Error: GOOGLE_APPLICATION_CREDENTIALS is not set"; exit 1; fi
	@if [ -z "$(GMAIL_PASSWORD)" ]; then echo "Error: GMAIL_PASSWORD is not set"; exit 1; fi

setup: ## Set up development dependencies
	@echo "==> Setting up development dependencies..."
	@if gcloud --version; then \
		echo "gcloud is installed. Stopping."; \
        exit 0; \
	else \
		echo "gcloud is not installed. Continuing..."; \
		brew --version; \
		brew install node; \
		npm install -g npm; \
		nvm install --lts; \
		brew install google-cloud-sdk; \
		gcloud init; \
	fi

install: ## Set up npm dependencies
	@echo "==> Installing npm dependencies..."
	npm install

login: ## Log in to gcloud CLI
	@echo "==> Logging in for gcloud cli..."
	gcloud auth login
	gcloud auth configure-docker $(GCP_ARTIFACT_PREFIX)

build: check-env ## Build the application
	@echo "==> Building the application..."
	npm run build

ci: check-env
	@echo ""
	npm ci

run: check-env ## Run the application locally
	@echo "==> Running the application locally..."
	npm start

clean: ## Clean up the build artifacts
	@echo "==> Cleaning up..."
	rm -rf dist

fresh: ## Remove the package-lock.json file
	@echo "==> Removing package-lock.json..."
	rm package-lock.json
	rm -rf node_modules
	npm install

local: ## Build artifact for local development
	@echo "==> Building local image with commit SHA $(COMMIT_SHA)..."
	docker build --platform linux/amd64 -t $(LOCAL_BUILD) .

deploy: install ## Deploy to Google Cloud Functions
	@echo "==> Building image with commit SHA $(COMMIT_SHA) and pushing to Google Artifact Registry..."
	docker build --platform linux/amd64 -t $(LOCAL_BUILD) .
	docker tag $(LOCAL_BUILD) $(FRONTEND_TAG)
	docker push $(FRONTEND_TAG)
	gcloud config set project $(GCP_PROJECT)
	gcloud run services update $(GCP_FRONTEND_NAME) --region us-west1 --image $(FRONTEND_TAG)

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
