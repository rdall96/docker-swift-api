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
- Added `Registry` type to represent a remote Docker server registry. Used for `Docker.login(server:username:password:)`.


## [1.3.0](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.3.0) (2023-08-25)

**Changed**
- Optional image digest in `Docker.Image` model. This will automatically be populated when an image object is initialized by the library.
- The `Container` model now has an additonal member to represent the `Image` that container is running.
- You can now automatically remove containers when they are stopped with the `removeWhenStopped` setting in `ContainerSpec`.
- Added `Docker.inspect(image:)` API to get information about an image on the system.
- Added `Docker.manifest(for:)` API to get manifests for image tags.
- `Docker.info` not longer returns an optional object.
- Pushing an image to a remove registry now returns the image manifest.
- Images now pull by default if they are misisng when using the `create(_:from:pull:)` and `run(image:with:pull:)` APIs.
- `Docker.Image` now conforms to `CustomStringConvertible`.
- New API to remove Docker volumes.
- `DockerHub.Image.architecture` now uses the `Docker.Platform.Architecture` data model.
