# Introduction #

The main purpose of `switchVersion.sh` is to allow for quick up-/downgrades of your TYPO3 core.

# Arguments #
```
$ ./switchVersion.sh --help
  Usage: ./switchVersion.sh [OPTIONS --version=<VERSION>]|<VERSION>

  Core:
  --help            Display this help and exit.
  --update          Tries to update the script to the latest version.
  --base=PATH       The name of the base path where TYPO3 is installed.
                    If no base is supplied, "typo3" is used.
  --export-config   Prints the default configuration of this script.
  --extract-config  Extracts configuration parameters from TYPO3.

  Options:
  --version=VERSION The version to switch to.

  Note: When using an external configuration file, it is sufficient to supply
        just the target version as a parameter.
        When supplying any other command line argument, supply the target
        version through the --version command line parameter.
```

## Overview ##

For general information regarding the configuration of scripts in the typo3scripts suite, please see the article about [Configuration](Configuration.md).

## `--help` ##
Prints the output seen above, giving an overview of available command line parameters.

## `--update` ##
Invokes the self-updating mechanism in this script. This will download the latest release version (from SVN trunk) from `code.google.com` and replace your current script.

Please note, every time the script runs it will perform a quick check if a new version is available. If a new version is found online, the following message will be printed to the standard output:
```
NOTE: New version available!
```

## `--base` / `BASE` ##
By default, it is assumed that the TYPO3 installation is located in a subfolder relative to the current working directory, named `typo3`. Use `--base` if the installation should be placed in a differently named subfolder.
```
$ ./switchVersion.sh --base=myt3site --version=4.6.2
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./switchVersion.sh --export-config > switchVersion.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file, like so:
```
$ ./switchVersion.sh --extract-config > switchVersion.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./switchVersion.sh --base=myt3site --extract-config > switchVersion.conf
```

## `--version` / `VERSION` ##
The version of TYPO3 we should switch to.

# Examples #

## Installation ##
```
/var/www$ cd t3site/
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/switchVersion.sh
/var/www/t3site$ chmod 700 switchVersion.sh
```

## Creating a snapshot ##
```
/var/www/t3site$ ./switchVersion.sh 4.6.3
Sourcing script configuration from typo3scripts.conf...Done.
Checking dependencies...Succeeded.
Looking for TYPO3 source package at typo3/typo3_src-4.6.3/...NOT found! Downloading.
Downloading http://prdownloads.sourceforge.net/typo3/typo3_src-4.6.3.tar.gz...Done.
Extracting source package typo3/typo3_src-4.6.3.tar.gz...Done.
Switching TYPO3 source symlink to typo3/typo3_src-4.6.3/...Done.
Checking if index.php needs to be updated...Done.
Deleting temp_CACHED_* files from typo3conf...Done!
Version switched to 4.6.3.
```
Please note, this example assumes that you previously created a configuration file `typo3scripts.conf` to share between scripts. Please see the article about [Configuration](Configuration.md) for more information.