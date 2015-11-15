# Introduction #

The main purpose of `createBackup.sh` is to create a snapshot of all files in the TYPO3 installation as well as the TYPO3 database. To restore such a snapshot use [restoreBackup.sh](RestoreBackupSh.md).

# Arguments #
```
$ ./createBackup.sh --help
  Usage: ./createBackup.sh [OPTIONS]

  Core:
  --help              Display this help and exit.
  --update            Tries to update the script to the latest version.
  --base=PATH         The name of the base path where TYPO3 is
                      installed. If no base is supplied, "typo3" is 
used.
  --export-config     Prints the default configuration of this script.
  --extract-config    Extracts configuration parameters from TYPO3.

  Database:
  --hostname=HOST     The name of the host where the TYPO3 database is running.
  --username=USER     The username to use when connecting to the TYPO3
                      database.
  --password=PASSWORD The password to use when connecting to the TYPO3
                      database.
  --database=DB       The name of the database in which TYPO3 is stored.
```

## Overview ##

For general information regarding the configuration of scripts in the typo3scripts suite, please see the article about [Configuration](Configuration.md).

**Hint**: It may be desirable to share a configuration file (at least) between `createBackup.sh` and `restoreBackup.sh`.

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
$ ./createBackup.sh --base=myt3site
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./createBackup.sh --export-config > createBackup.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file, like so:
```
$ ./createBackup.sh --extract-config > createBackup.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./createBackup.sh --base=myt3site --extract-config > createBackup.conf
```

## `--hostname` / `HOST` ##
The name of the host where the database for TYPO3 is running.

## `--username` / `USER` ##
The username for the connection to the database for the TYPO3 installation.

## `--password` / `PASS` ##
The password for the connection to the database for the TYPO3 installation.

## `--database` / `DB` ##
The name of the database for the TYPO3 installation.

# Examples #

## Installation ##
```
/var/www$ cd t3site/
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/createBackup.sh
/var/www/t3site$ chmod 700 createBackup.sh
```

## Creating a snapshot ##
```
/var/www/t3site$ ./createBackup.sh
Sourcing script configuration from typo3scripts.conf...Done.
Checking dependencies...Succeeded.
Creating TYPO3 backup 'typo3-2012-02-12-18-35.tgz'...
Creating database dump at typo3/database.sql...Done.
Compressing TYPO3 installation...Done.
Deleting database dump...Done!
```
Please note, this example assumes that you previously created a configuration file `typo3scripts.conf` to share between scripts. Please see the article about [Configuration](Configuration.md) for more information.