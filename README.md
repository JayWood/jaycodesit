# JayCodesIt.com
This is my personal website, if you really want to copy me feel free to do so.
This project was built to prove to myself I knew what I was doing with
kubernetes. It's built as both a side project and as a learning experience for
kubernetes development.

The project runs on my own Kubernetes Node which I setup myself. There are a few
undocumented secrets because for obvious reasons I thought it best not to store
those values in the repository.

## Features

Kubernetes
* Persistent volume/claims
  * MySQL Database
  * Wordpress wp-content/uploads
* Custom Backup shell script
  * Backs data up to google drive.
  * Only the SQl database and uploads folder, rest is managed by this repository so no additional control is required.
* Ingress manifest
  * Complete with certs for Cloudflare.
* Sql User/Password managed via Github Secrets

> While the secrets for mysql can be managed internally similarly to the google drive secret
> I wanted to see how this could be done through github at the time. This will be updated later most likely.

Wordpress
* Docker WordPress Core image.
  * Custom dockerfile extends the image.
  * Installs a few custom scripts and applications for backups.
* Overrides the entrypoint for custom code & CLI.
* Installs WP-CLI in the docker image for backup reasons.
* All custom WordPress code is listed under `/src/`
* Composer managed plugins.
* Docker-managed WordPress version.
* NPM installed purely for `npm version <major|minor|patch>`.

MySQL
* Nothing special here, singular database designed solely for this project.
