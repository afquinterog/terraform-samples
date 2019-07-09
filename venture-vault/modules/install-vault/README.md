# Vault Install Script

Venture base script to build the vault base AMI


## Quick start

To install Vault, use `git` to clone this repository at a specific tag (see the [releases page](../../../../releases)
for all available tags) and run the `install-vault` script:

```
git clone --branch <VERSION> https://github.com/hashicorp/terraform-aws-vault.git
venture-vault/modules/install-vault/install-vault --version 1.1.3
```

The `install-vault` script will install Vault, its dependencies, and the [run-vault script].

You can then run the `run-vault` script when the server is booting to start Vault.


## Command line Arguments

The `install-vault` script accepts the following arguments:

* `version VERSION`: Install Vault version VERSION. Optional if download-url is provided.
* `download-url URL`: Install the Vault package hosted in this url. Optional if version is provided.
* `path DIR`: Install Vault into folder DIR. Optional.
* `user USER`: The install dirs will be owned by user USER. Optional.

Example:

```
install-vault --version 1.1.3
```

## How it works

The `install-vault` script does the following:

1. [Creates a user and folders for Vault](#create-a-user-and-folders-for-vault)
1. [Installs Vault binaries and scripts](#install-vault-binaries-and-scripts)
1. [Configures mlock](#configure-mlock)
1. [Follow-up tasks](#follow-up-tasks)


### Creates a user and folders for Vault

Creates an OS user named `vault`. Creates the following folders, all owned by user `vault`:

* `/opt/vault`: base directory for Vault data (configurable via the `--path` argument).
* `/opt/vault/bin`: directory for Vault binaries.
* `/opt/vault/data`: directory where the Vault agent can store state.
* `/opt/vault/config`: directory where the Vault agent looks up configuration.
* `/opt/vault/log`: directory where the Vault agent will store log files.
* `/opt/vault/tls`: directory where the Vault will look for TLS certs.


### Installs Vault binaries and scripts

Installs the following:

* `vault`: Either downloads the Vault zip file from the [downloads page](https://www.vaultproject.io/downloads.html) (the
  version number is configurable via the `--version` argument) , or a package hosted on a precise url configurable with `--dowload-url`
  (useful for installing Vault Enterprise, for example), and extracts the `vault` binary into `/opt/vault/bin`. Adds a
  symlink to the `vault` binary in `/usr/local/bin`.
* `run-vault`: Copies the [run-vault script] into `/opt/vault/bin`.


### Configures mlock

Gives Vault permissions to make the `mlock` (memory lock) syscall. This syscall is used to prevent the OS from swapping
Vault's memory to disk. For more info, see: https://www.vaultproject.io/docs/configuration/#disable_mlock.


### Follow-up tasks

After the `install-vault` script finishes running, you may wish to do the following:

1. If you have custom Vault config (`.hcl`) files, you may want to copy them into the config directory (default:
   `/opt/vault/config`).
1. If `/usr/local/bin` isn't already part of `PATH`, you should add it so you can run the `vault` command without
   specifying the full path.



## Dependencies

The install script assumes that `systemd` is already installed.  We use it as a cross-platform supervisor to ensure Vault is started
whenever the system boots and restarted if the Vault process crashes.  Additionally, it is used to store all logs which can be accessed
using `journalctl`.

