# Change Log

## [1.0.0](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.0.0) (2023-07-20)
           
**Changed**
- Created Swift API to use Docker CLI on localhost to execute Docker actions and commands.
- API supports managing both images and containers, as well as fetching the API info and authenticating on remote registries.
- DockerHub support to query repositories and image tags.

## [1.0.1](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.0.1) (2023-07-24)

**Changed**
- Removed `--quiet` flag from Docker commands since it's not compatible with all Docker CLIs

## [1.1.0](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.1.0) (2023-08-09)

**Changed**
- Removed `detach` argument from `run` and `exec` APIs since it doesn't really make sense to use in a method context.
- Added `build` API to create new Docker images, and return a buidl result containing the output of the build as well as the name of the image tagged.
- Added API to tag existing images with `Docker.tag(_:source:)`.
- Added API to push images to a remote repository with `Docker.push(_:)`.
- `Docker.exec` no longer returns the output of the command (because it never worked).

## [1.2.0](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.2.0) (2023-08-20)

**Changed**
- Ability to specify if the image should be pulled before creating and/or running a container.
- `ContainerSpec.PortMapping` object to specify more properties about the port, like the port type (i.e.: TCP, UDP, etc...).
- `ContainerSpec.EnvironmentVariable` object to represent environment variables passed to the contianer.
- Docker volumes support to create volumes on the system, with APIs to list existing volumes and create new ones.
- `ContainerSpec.VolumeMapping` object to represent volumes and paths mapped to the container.
- `Docker.exec` now returns the command output.
- Added `Registry` type to represent a remote Docke rserver registry. Used for `Docker.login(server:username:password:)`.
