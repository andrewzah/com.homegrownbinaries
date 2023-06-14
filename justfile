docker-build:
  docker build . -t andrewzah/homegrownbinaries:latest

docker:
  just docker-build
  just docker-push

docker-push:
  docker push andrewzah/homegrownbinaries:latest
