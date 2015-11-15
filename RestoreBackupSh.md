# Introduction #

The main purpose of `restoreBackup.sh` is to restore snapshots previously created by [createBackup.sh](CreateBackupSh.md). It is unlikely to have any use as a stand-alone script.

# Privileges #

Due to the fact that `restoreBackup.sh` tries to delete the TYPO3 base installation folder, elevated privileges (`sudo`) might be required. This is required because TYPO3 most likely created files in the installation folder that are now owned by the user that runs the HTTP daemon. See the following example output displaying the issue noted above.

```
/var/www/t3site$ ./restoreBackup.sh typo3-2012-01-02-17-56.tgz
Sourcing script configuration from restoreBackup.conf...Done.
Testing write permissions in typo3...Failed!
typo3/typo3conf/temp_CACHED_pse643_ext_localconf.php is not writable!
```

To work around this issue, you could rename the TYPO3 base installation directory and re-create it.

```
/var/www/t3site$ mv typo3 backup
/var/www/t3site$ mkdir typo3
/var/www/t3site$ ./restoreBackup.sh typo3-2012-01-02-17-56.tgz
Sourcing script configuration from restoreBackup.conf...Done.
Testing write permissions in typo3...Succeeded
Erasing current TYPO3 installation 'typo3'...Done.
Extracting TYPO3 backup 'typo3-2012-01-02-17-56.tgz'...Done.
Importing database dump...Done.
Deleting database dump...Done!
```

# Arguments #
```
$ ./restoreBackup.sh --help
  Usage: ./restoreBackup.sh [OPTIONS --file=<FILE>]|<FILE>

  Core:
  --help              Display this help and exit.
  --update            Tries to update the script to the latest version.
  --base=PATH         The name of the base path where TYPO3 is
                      installed. If no base is supplied, "typo3" is used.
  --export-config     Prints the default configuration of this script.
  --extract-config    Extracts configuration parameters from TYPO3.

  Options:
  --file=FILE         The file in which the backup is stored.

  Database:
  --hostname=HOST     The name of the host where the TYPO3 database is running.
  --username=USER     The username to use when connecting to the TYPO3
                      database.
  --password=PASSWORD The password to use when connecting to the TYPO3
                      database.
  --database=DB       The name of the database in which TYPO3 is stored.

  Note: When using an external configuration file, it is sufficient to supply
        just the name of the file that contains the backup as a parameter.
        When supplying any other command line argument, supply the target file
        through the --file command line parameter.
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
By default, it is assumed that the TYPO3 installation is located in a subfolder relative to the current working directory, named `typo3`. Use `--base` if the installation is placed in a differently named subfolder.
```
$ ./restoreBackup.sh --base=myt3site --file=myt3site-2012-01-02-14-25.tgz
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./restoreBackup.sh --export-config > restoreBackup.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file, like so:
```
$ ./restoreBackup.sh --extract-config > restoreBackup.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./restoreBackup.sh --base=myt3site --extract-config > restoreBackup.conf
```

## `--file` / `FILE` ##
The name of the snapshot file that should be restored.

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
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/restoreBackup.sh
/var/www/t3site$ chmod 700 restoreBackup.sh
```

## Restoring a snapshot ##
```
/var/www/t3site$ sudo ./restoreBackup.sh typo3-2012-02-12-18-35.tgz
Sourcing script configuration from typo3scripts.conf...Done.
Checking dependencies...Succeeded.
Testing write permissions in typo3...Succeeded
Erasing current TYPO3 installation 'typo3'...Done.
Extracting TYPO3 backup 'typo3-2012-02-12-18-35.tgz'...Done.
Importing database dump...Done.
Deleting database dump...Done!
```

Please note, this example assumes that you previously created a configuration file `typo3scripts.conf` to share between scripts. Please see the article about [Configuration](Configuration.md) for more information.