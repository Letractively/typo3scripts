# Introduction #

The main purpose of `extUpdate.sh` is to retrieve the version of the latest update for a given TYPO3 extension (or all TYPO3 extensions) and compare it to the version of the locally installed copy.
Optionally, if ExtChangelogSh is available as well, the upload comments for the pending updates can be displayed.

# Arguments #
```
$ ./extUpdate.sh --help
  Usage: ./extUpdate.sh [OPTIONS]

  Core:
  --help              Display this help and exit.
  --update            Tries to update the script to the latest version.
  --base=PATH         The name of the base path where Typo3 is
                      installed. If no base is supplied, "typo3" is used.
  --export-config     Prints the default configuration of this script.
  --extract-config    Extracts configuration parameters from TYPO3.

  Options:
  --extension=EXTKEY  The extension key of the extension that should be
                      operated on.
  --changelog         Display the upload comments for updated extensions.

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
$ ./extUpdate.sh --base=myt3site
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./extUpdate.sh --export-config > typo3scripts.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file for other typo3scripts after you have completed your TYPO3 installation.
```
$ ./extUpdate.sh --extract-config > typo3scripts.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./extUpdate.sh --base=myt3site --extract-config > typo3scripts.conf
```

## `--extension` / `EXTENSION` ##
Tells `extUpdate.sh` for what extension it should retrieve the latest version. If no extension is specified, it will list all extensions that have updates pending.
```
$ ./extUpdate.sh --extension=div2007
```

## `--changelog` / `DISPLAY_CHANGELOG` ##
Tells `extUpdate.sh` to invoke ExtChangelogSh to retrieve upload comments for the pending updates.
```
$ ./extUpdate.sh --changelog
```

## `--hostname` / `HOST` ##
The name of the host where the database for TYPO3 is running.

## `--username` / `USER` ##
The username for the connection to the database for the TYPO3 installation.

## `--password` / `PASS` ##
The password for the connection to the database for the TYPO3 installation. If not defined, `bootstrap.sh` will try to initialize the password to a random 16 character string.

## `--database` / `DB` ##
The name of the database for the TYPO3 installation. This parameter is currently unused.

# Examples #

## Installation ##
```
/var/www$ cd t3site/
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/extUpdate.sh
/var/www/t3site$ chmod 700 extUpdate.sh
```

## Checking for updates ##
```
/var/www/t3site$ ./extUpdate.sh
Sourcing script configuration from typo3scripts.conf...Done.
Checking dependencies...Succeeded.
New version of 'direct_mail' available. Installed: 2.6.10 Latest: 2.7.0
New version of 'div2007' available. Installed: 0.7.2 Latest: 0.8.1
New version of 'kb_md5fepw' available. Installed: 0.4.0 Latest: 0.4.1
```
Please note, this example assumes that you previously created a configuration file `typo3scripts.conf` to share between scripts. Please see the article about [Configuration](Configuration.md) for more information.

## Checking for updated (using `extChangelog.sh`) ##
If ExtChangelogSh is also present in the same folder as `extUpdate.sh`, upload comments can be shown for pending updates:
```
/var/www/t3site$ ./extUpdate.sh --changelog
Sourcing script configuration from typo3scripts.conf...Done.
Checking dependencies...Succeeded.
New version of 'direct_mail' available. Installed: 2.6.10 Latest: 2.7.0
2.7.0 (2012-01-30 00:44:37)
  - layout tweaking
  - create draft newsletter and auto sending (e.g. weekly) (thanks to Benni Mack)
  - bug fixes
  please refer to changelog for further info.
  please report any bug or feature or anything in Forge (forge.typo3.org)

New version of 'div2007' available. Installed: 0.7.2 Latest: 0.8.1
0.8.0 (2012-01-23 21:19:28)
  add new classes for email and error message generation
  ready for TYPO3 4.6
0.8.1 (2012-01-28 18:10:45)
  allow the usage of a pibase object instead of class.tx_div2007_alpha_language_base

New version of 'kb_md5fepw' available. Installed: 0.4.0 Latest: 0.4.1
0.4.1 (2010-10-27 21:04:19)
  DEPRECATED: Use "saltedpasswords" and "rsaauth" extensions instead!
```
Please note, this example assumes that you previously created a configuration file `typo3scripts.conf` to share between scripts. Please see the article about [Configuration](Configuration.md) for more information.

## Checking for local modifications ##
If you have local modifications in an extension and you want to know what it was that you modified, you should use ExtExtractPhp and `diff`. There is an example on the wiki page for ExtExtractPhp.