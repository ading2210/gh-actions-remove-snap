# Remove Snap Completely in Github Actions

This Github Action removes the Snap package manager from Ubuntu runners. It also configures APT to never install Snap again, and optionally sets up the Mozilla APT repository so that the installed version of Firefox no longer relies on Snap. 

## Why?

Sometimes, you need to install new packages onto the Github-hosted Ubuntu runners. When you do this, you need to do a `sudo apt-get update` and a `sudo apt-get upgrade` before installing anything, but doing that causes Snapd (and the preinstalled Firefox Snap) to be updated as well. When that happens, it causes a several minute delay and possible random failures. 

## How?

Simply add this as a step in your existing workflow:

```yaml
name: run build
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: remove snap
        uses: ading2210/gh-actions-remove-snap@v1
```

This action accepts the following inputs:

```yaml
inputs:
  reinstall_firefox:
    description: "If set to true, Firefox will be reinstalled using the Mozilla APT repo. Otherwise, Firefox will be held back from upgrading."
    required: false
    default: false
```

Note that if the action runs on a non-Linux runner, it will be skipped. 

## License

This repository is licensed under the MIT license.