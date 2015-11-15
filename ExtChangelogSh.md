# Introduction #

The main purpose of `extChangelog.sh` is to retrieve the upload comments for a given TYPO3 extension from the cached extension information in the database.

# Arguments #
```
$ ./extChangelog.sh --help
  Usage: ./extChangelog.sh [OPTIONS] [--extension=]EXTKEY

  Core:
  --help              Display this help and exit.
  --update            Tries to update the script to the latest version.
  --base=PATH         The name of the base path where Typo3 is
                      installed. If no base is supplied, "typo3" is used.
  --export-config     Prints the default configuration of this script.
  --extract-config    Extracts configuration parameters from TYPO3.

  Options:
  --extension=EXTKEY  The extension key of the extension for which to retrieve
                      the changelog.
  --first=VERSION     The first version that should be listed.
  --last=VERSION      The last version that should be listed.
  --skip-first        Skip the first found version.

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
$ ./extChangelog.sh --base=myt3site --extension=news
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./extChangelog.sh --export-config > typo3scripts.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file for other typo3scripts after you have completed your TYPO3 installation.
```
$ ./extChangelog.sh --extract-config > typo3scripts.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./extChangelog.sh --base=myt3site --extract-config > typo3scripts.conf
```

## `--extension` / `EXTENSION` ##
Tells `extChangelog.sh` for what extension it should retrieve the upload comments. It should be the usual extension key.
```
$ ./extChangelog.sh --extension=news
```

## `--first` / `VERSION_FIRST` ##
The first version from the upload comments that should printed. If `--skip-first` is also supplied, the version after this one will be the first one.
```
$ ./extChangelog.sh --extension=news --first=1.2.0
```

## `--last` / `VERSION_LAST` ##
The last version from the upload comments that should printed. All entries after this version are ignored.
```
$ ./extChangelog.sh --extension=news --last=1.3.0
```

## `--skip-first` / `SKIP_FIRST` ##
Skips printing the first version. This is mostly intended for the integration with ExtUpdateSh.
```
$ ./extChangelog.sh --extension=news --first=1.2.0 --skip-first
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
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/extChangelog.sh
/var/www/t3site$ chmod 700 extChangelog.sh
```

## Looking up a complete history of upload comments ##
```
/var/www/t3site$ ./extChangelog.sh --extension=news
Sourcing script configuration from typo3scripts.conf...Done.
Checking dependencies...Succeeded.
Retrieving upload comment history...Done.
1.0.0 (2011-09-09 09:15:08)
  Initial release to TER! News based on extbase & fluid
1.1.0 (2011-10-05 10:00:49)
  Bugfixes and minor features. Also see http://forge.typo3.org/projects/extension-news/wiki for Howtos!
1.2.0 (2011-11-15 22:47:50)
  bugfixes features. please read section "breaking changes" in manual
1.2.3 (2011-11-17 07:44:17)
  again a bugfix, again sorry guys
1.3.0 (2011-12-19 10:28:37)
  Lots of new features, see http://forge.typo3.org/projects/extension-news/wiki/Release_Notes Merry Christmas!!
1.3.1 (2011-12-19 19:07:52)
  Lots of new features, see http://forge.typo3.org/projects/extension-news/wiki/Release_Notes Merry Christmas!!

```
Please note, this example assumes that you previously created a configuration file `typo3scripts.conf` to share between scripts. Please see the article about [Configuration](Configuration.md) for more information.