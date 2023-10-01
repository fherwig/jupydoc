# Makefile for building Docker image

# Name of your Docker image
IMAGE_NAME = jupydoc

# Local build
build:
	@echo "Building Docker image for local development..."
	docker build -t $(IMAGE_NAME):latest .

# No cache build
no-cache:
	@echo "Building Docker image without cache..."
	docker build --no-cache -t $(IMAGE_NAME):latest .

# Release build
release:
	@echo "Building Docker image for release..."
	docker build -t $(IMAGE_NAME):latest .

