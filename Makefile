NAME := toolbox
DOCKER_USER := ukhomeofficedigital
VERSION := 0.0.1
REGISTRY := quay.io
DATE := $(shell date)
GITMESSAGE = $(git log -1 --pretty=%B)

.PHONY: all help build run shell test tag_latest release

all: clean build run

help:
	@echo ""
	@echo "Usage for offline-pull"
	@echo ""
	@echo "Build the container:"
	@echo "  make build"
	@echo ""
	@echo "Run the container with defaults:"
	@echo "  make run"
	@echo ""
	@echo "Test the container:"
	@echo "  make test"
	@echo ""
	@echo "Start the container in interactive mode:"
	@echo "  make shell"
	@echo ""
	@echo "Tag the container:"
	@echo "  make tag_latest"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean"
	@echo ""
	@echo "Push container to repository:"
	@echo "  make release"

build:
	docker build -t $(DOCKER_USER)/$(NAME):$(VERSION) --rm=true .

shell:
	docker run --rm --name $(NAME) --net=host -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --privileged -it --entrypoint="/bin/bash" $(DOCKER_USER)/$(NAME):$(VERSION)

shell_osx:
	docker run --rm --name $(NAME) --net=host -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --privileged -it --entrypoint="/bin/bash" $(DOCKER_USER)/$(NAME):$(VERSION)

logs:
	docker logs -f $(NAME)

tag_latest:
	@echo
	@echo "Preparing release tag."
	@./utils/preparerelease.sh $(NAME) $(VERSION)
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(REGISTRY)/$(NAME):$(VERSION)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
