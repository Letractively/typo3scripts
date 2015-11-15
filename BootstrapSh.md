# Introduction #

The main purpose of `bootstrap.sh` is to ease deployment of a new TYPO3 installation.

# Arguments #
```
$ ./bootstrap.sh --help
  Usage: ./bootstrap.sh [OPTIONS --version=<VERSION>]|<VERSION>

  Core:
  --help              Display this help and exit.
  --update            Tries to update the script to the latest version.
  --base=PATH         The name of the base path where TYPO3 should be
                      installed. If no base is supplied, "typo3" is used.
  --export-config     Prints the default configuration of this script.
  --extract-config    Extracts configuration parameters from TYPO3.

  Options:
  --version=VERSION   The version to install.
  --skip-db-config    Skips writing the database configuration to localconf.php
  --skip-gm-detect    Skips the detection of GraphicsMagick.
  --skip-unzip-detect Skips the detection of the unzip utility.
  --skip-rights       Skip trying to fix access rights.
  --owner=OWNER       The name of the user that owns the installation.
  --httpd-group=GROUP The user group the local HTTP daemon is running as.
  --fix-indexphp      Replaces the index.php symlink with the actual file.

  Database:
  --hostname=HOST     The name of the host where the TYPO3 database is running.
  --username=USER     The username to use when connecting to the TYPO3
                      database.
  --password=PASSWORD The password to use when connecting to the TYPO3
                      database.
  --database=DB       The name of the database in which TYPO3 is stored.

  Note: When using an external configuration file, it is sufficient to supply
        just the target version as a parameter.
        When supplying other any command line argument, supply the target
        version through the --version command line parameter.
```

## Overview ##

For general information regarding the configuration of scripts in the typo3scripts suite, please see the article about [Configuration](Configuration.md).

**Hint**: It may be desirable to construct a configuration file for `bootstrap.sh` right away (even though you might only be using the script once) as other scripts in this suite can use the same configuration file.

## `--help` ##
Prints the output seen above, giving an overview of available command line parameters.

## `--update` ##
Invokes the self-updating mechanism in this script. This will download the latest release version (from SVN trunk) from `code.google.com` and replace your current script.

Please note, every time the script runs it will perform a quick check if a new version is available. If a new version is found online, the following message will be printed to the standard output:
```
NOTE: New version available!
```

## `--base` / `BASE` ##
By default, TYPO3 installations will be created in a subfolder relative to the current working directory, named `typo3`. Use `--base` if the installation should be placed in a differently named subfolder.
```
$ ./bootstrap.sh --version=4.6.0 --base=myt3site
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./bootstrap.sh --export-config > typo3scripts.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file for other typo3scripts after you have completed your TYPO3 installation.
```
$ ./bootstrap.sh --extract-config > typo3scripts.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./bootstrap.sh --base=myt3site --extract-config > typo3scripts.conf
```

## `--version` / `VERSION` ##
The version of TYPO3 that should be installed.

## `--skip-db-config` / `SKIP_DB_CONFIG` ##
Unless this parameter is given, `bootstrap.sh` will write database related parameters to the TYPO3 `localconf.php`.

## `--skip-gm-detect` / `SKIP_GM_DETECT` ##
Unless this parameter is given, `bootstrap.sh` will look for a GraphicsMagick binary and, if found, write the location to the TYPO3 `localconf.php` as `$TYPO3_CONF_VARS['GFX']['im_version_5']`.

## `--skip-unzip-detect` / `SKIP_UNZIP_DETECT` ##
Unless this parameter is given, `bootstrap.sh` will look for an `unzip` binary and, if found, write the location to the TYPO3 `localconf.php` as `$TYPO3_CONF_VARS['BE']['unzip_path']`.

## `--skip-rights` / `SKIP_RIGHTS` ##
Unless this parameter is given, `bootstrap.sh` will try to adjust access rights for the new TYPO3 installation. Please note that fixing the access rights requires the script to run with elevated privileges (`sudo`).

## `--owner` / `OWNER` ##
Defines the name of the system user that should own the new TYPO3 installation.

## `--httpd-group` / `HTTPD_GROUP` ##
Defines the name of the system group the web server that serves the TYPO3 installation is running as. This should be something like `www-data` (the default) or `apache`.

## `--fix-indexphp` / `FIX_INDEXPHP` ##
Using this option will remove the symbolic link for `index.php` and replace it with a copy of the actual file. The symlink causes problems with certain hosting providers.
Please note, SwitchVersionSh is aware if this approach was used during an installation and will keep the copied file up-to-date for you.

## `--hostname` / `HOST` ##
The name of the host where the database for TYPO3 is running.

## `--username` / `USER` ##
The username for the connection to the database for the TYPO3 installation.

## `--password` / `PASS` ##
The password for the connection to the database for the TYPO3 installation. If not defined, `bootstrap.sh` will try to initialize the password to a random 16 character string.

## `--database` / `DB` ##
The name of the database for the TYPO3 installation. This parameter is currently unused.

# Examples #

## Creating a fresh installation ##
```
/var/www$ mkdir t3site
/var/www$ cd t3site/
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/bootstrap.sh
/var/www/t3site$ chmod 700 bootstrap.sh
/var/www/t3site$ sudo ./bootstrap.sh 4.6.4
Checking dependencies...Succeeded.
Looking for TYPO3 package at blankpackage-4.6.4.tar.gz...NOT found!
Downloading http://prdownloads.sourceforge.net/typo3/blankpackage-4.6.4.tar.gz...Done.
Extracting TYPO3 package blankpackage-4.6.4.tar.gz...Done.
Moving TYPO3 package to typo3...Done.
Generating localconf.php...Done.
Enabling install tool...Done.
Adjusting access permissions for TYPO3 installation...Done.

Your TYPO3 Install Tool password is: 'df5798c18bad9901'
```
Creating a new installation is straight-forward. You simply retrieve the script, make it executable and pass the TYPO3 version you want to use as an argument.

By default, the installation will be created in a subfolder called `typo3`. This is due to the way the other scripts interact with a TYPO3 installation. You can change the name of that subfolder with the `--base` command line parameter.

Additionally, `bootstrap.sh` accepts parameters related to the database TYPO3 should use. `bootstrap.sh` accepts these parameters for interoperability reasons with other scripts in this suite (which require a database connection). This allows you to construct a single configuration which all scripts can make use of.
These parameters will be written to the TYPO3 `localconf.php` file (unless disabled via `--skip-db-config`).

After completing the 1-2-3 setup wizard on your site, it may be desirable to extract the configuration entries into a configuration file for typo3scripts to use. That topic is discussed in the article about [Configuration](Configuration.md).