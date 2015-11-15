# Introduction #

In this article we will look at all the different ways to configure the scripts found in this project. We will also present recommended configuration approaches.

# Details #

## Configuration Order ##
There are 4 candidates when determining configuration for a script in the typo3scripts script suite.

  1. The internal, hard-coded defaults inside the script.
  1. Values read from the `typo3scripts.conf` general configuration file.
  1. Values read from the script-specific `<scriptname>.conf` configuration file.
  1. Arguments passed to the script on the command line.

Every script in the suite will follow this order when reading values into the configuration items for the specific script.

## Configuration Files ##
The easiest way to set up a configuration for any script in the typo3scripts suite, just run the script with the `--export-config` parameter. For example:
```
$ ./extUpdate.sh --export-config > typo3scripts.conf
$ chmod 600 typo3scripts.conf
```
This would generate the configuration file `typo3scripts.conf`. Which is always the first **file** any script will try to read configuration items from.

If you want to manually create the configuration file, the correct contents for that configuration file can always be taken from the scripts themselves. It is contained between the `# Script Configuration start` and `# Script Configuration end` markers.
In fact, `--export-config` just extracts that block from the script itself. Nevertheless, it is recommended to always use `--export-config`, as it may apply transformations to the configuration file format.

The configuration items in that file will contain the settings specific to `extUpdate.sh`, but all common, shared settings are contained there as well. So using the file should be without complications.

You should now adjust items in the base configuration, like the `BASE` path. The `BASE` path is the path, relative to the currently executed script, where TYPO3 is installed. By default, all typo3scripts will assume the `BASE` is a subfolder called `typo3`.

If you need to, you can always override settings from the `typo3scripts.conf` configuration file for a specific script in its script-specific configuration file.
The script-specific configuration files are always named like the script they are intended for with the file extension replaced with `.conf`.

## Database Configuration ##

After having the base configuration file, if you have an existing TYPO3 installation, you can pull in the database configuration like so:
```
$ ./extUpdate.sh --extract-config >> typo3scripts.conf
$ chmod 600 typo3scripts.conf
```

Now all scripts should be able to use it for their operation. So you never have to supply and database-related parameters on the command line.

## Recommended Configuration ##
Usually you'll want to only have a single `typo3scripts.conf` file with the configuration for database access and the base installation directory. The script-specific configuration files should only rarely required.