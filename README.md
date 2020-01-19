# CollabNet Subversion Edge BOSH Release

[![GitHub release](https://img.shields.io/github/v/release/a2geek/subversion-edge-bosh-release)](https://github.com/a2geek/subversion-edge-bosh-release/releases/latest)

This is a BOSH Release to deploy [Subversion Edge](https://www.collab.net/products/subversion).

## Important

This release installs the entirety of Subversion Edge into `/var/vcap/store/csvn`. This includes Jetty, Apache HTTPd, Subversion, Subversion Edge, and all other components. Originally this was due to the fact that separating the "data" from the "application" was difficult, at best. Ultimately, it was realized that this means product upgrades work naturally and persist.

## Motivation

I have kept source code in some form of a version control system since introduced to them. Much of that historical code ultimately landed in various Subversion repositories. This project is to help maintain that legacy of code which noone but myself cares about.

## Status

Works! Very little configuration capabilities at this time. Ports are currently the default of `3343` and `4434` for CSVN; and (somehow) `80` for SVN itself.

It remains as an experiment to place this behind HAProxy and get all configuration mechanisms aligned.

# Deployment

```
git clone https://github.com/a2geek/subversion-edge-bosh-release.git
cd subversion-edge-bosh-release
bosh -d csvn deploy manifest.yml
```

## Configuration options

| Operations File | Description |
| --- | --- |
| `operations/set-disk-size.yml` | Used to set a different disk size from the arbitratily chosen size of 10GiB. |

## Configuration variables

Structured variables will be similar to this:

```
csvn:
  disk_size: ...
```

## Post-deployment

As Subversion Edge manages all the configuration files, nearly all configuration needs to be done via the user interface.

# Development

For those used to `make` the delete/deploy sequences are just:

```
make rmdev dev
```
> Note: `rmdev` is to remove existing dev. Don't use the first time. ;-)

Otherwise, the usual mechanisms:

```
cd subversion-edge-bosh-release
bosh create-release --force
bosh upload-release
bosh -d csvn deploy manifest.yml -o operations/use-latest-dev.yml
```
