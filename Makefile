.PHONY:	build-docker

TAG?=latest
IMAGE?=nkijak/book-binder:$(TAG)


build-docker:
	docker build -m 8g -t $(IMAGE) .

shell:
	docker run --rm \
	-it \
	--env DIST=/book \
	--volume $(PWD):/book \
	--volume $(PWD)/../Arduino-Inspiration-Code:/Arduino-Inspiration-Code  \
	$(IMAGE) \
	sh
