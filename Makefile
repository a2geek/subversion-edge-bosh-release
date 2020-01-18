RELEASE=subversion-edge-bosh-release

help:
	@echo Please specify valid target: dev, rmdev, release, final-release

dev:
	bosh create-release --force
	bosh upload-release
	bosh -n -d csvn deploy manifest.yml \
	     -o operations/use-latest-dev.yml

rmdev:
	bosh -n -d csvn delete-deployment

release:
	bosh create-release --force --tarball $(PWD)/$(RELEASE).tgz

final-release:
	last_tag=$$(git describe --tags --abbrev=0); \
	if grep "version: $${last_tag}" releases/$(RELEASE)/index.yml > /dev/null; \
	then \
		echo "Nothing to do."; \
	else \
		bosh create-release --final --version=$${last_tag} --tarball=$(RELEASE).tgz; \
		sha1sum $(PWD)/$(RELEASE).tgz; \
	fi
