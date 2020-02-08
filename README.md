# CollabNet Subversion Edge BOSH Release

[![GitHub release](https://img.shields.io/github/v/release/a2geek/subversion-edge-bosh-release)](https://github.com/a2geek/subversion-edge-bosh-release/releases/latest)

This is a BOSH Release to deploy [Subversion Edge](https://www.collab.net/products/subversion).

## Important

This release installs the entirety of Subversion Edge into `/var/vcap/store/csvn`. This includes Jetty, Apache HTTPd, Subversion, Subversion Edge, and all other components. Originally this was due to the fact that separating the "data" from the "application" was difficult, at best. Ultimately, it was realized that this means product upgrades work naturally and persist.

## Motivation

I have kept source code in some form of a version control system since introduced to them. Much of that historical code ultimately landed in various Subversion repositories. This project is to help maintain that legacy of code which noone but myself cares about.

## Status

Works! Very little configuration capabilities at this time. Ports are currently the default of `3343` and `4434` for CSVN; and (somehow) `80` for SVN itself.

# Deployment

```
git clone https://github.com/a2geek/subversion-edge-bosh-release.git
cd subversion-edge-bosh-release
bosh -d csvn deploy manifest.yml
```

## HAProxy notes

This deployment is currently deployed behind HAProxy. My configuration uses BOSH DNS for internal resolution, so these snippets are based on that configuration and are edited to be more direct.

> Note that the HAProxy health check does generate a lot of `GET /` type logs. Mostly for awareness.

```
  frontend http-in
    mode http

    # Redirect all HTTP traffic to HTTPS
    bind *:80
    redirect scheme https if !{ ssl_fc } !{ hdr(host) -i repo.gdc.lan }

    # HTTPS
    bind *:443 ssl crt /var/vcap/jobs/haproxy/config/ssl/cert-0.pem

    # Define hosts
    acl path_svn path_beg /svn
    acl path_viewvc path_beg /viewvc
    acl host_csvn hdr(host) -i svn.gdc.lan

    # Route to correct host
    use_backend svn_deployment if host_csvn path_svn
    use_backend svn_deployment if host_csvn path_viewvc
    use_backend csvn_deployment if host_csvn

  backend csvn_deployment
    mode http
    balance leastconn
    option httpclose
    option forwardfor
    option httpchk GET /
    cookie JSESSIONID prefix
    server web csvn.service.csvn.internal:3343 check inter 1000 fall 3 rise 2 port 3343

  backend svn_deployment
    mode http
    balance leastconn
    option httpclose
    option forwardfor
    http-check expect status 401
    option httpchk GET /
    server web csvn.service.csvn.internal:80 check inter 1000 fall 3 rise 2 port 80
```

The BOSH DNS configuration contains this snippet to configure CSVN:

```
  - domain: csvn.service.csvn.internal
    targets:
    - query: '*'
      instance_group: csvn
      deployment: csvn
      network: default
      domain: bosh
```

Note that BOSH DNS must be added in. [`cf-deployment.yml`](https://github.com/cloudfoundry/cf-deployment/blob/master/cf-deployment.yml) was a good reference and example to start with.

## Configuration options

| Operations File | Description |
| --- | --- |
| `operations/set-disk-size.yml` | Used to set a different disk size from the arbitratily chosen size of 2GiB. |

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
