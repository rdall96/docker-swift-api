# Change Log

## [1.0.0](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.0.0) (2023-07-20)
           
**Changed**
- Created Swift API to use Docker CLI on localhost to execute Docker actions and commands.
- API supports managing both images and containers, as well as fetching the API info and authenticating on remote registries.
- DockerHub support to query repositories and image tags.

## [1.0.1](https://gitlab.com/rdall96/docker-swift-api/-/releases/1.0.1) (2023-07-24)

**Changed**
- Removed `--quiet` flag from Docker commands since it's not compatible with all Docker CLIs
