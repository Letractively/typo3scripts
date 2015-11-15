# Introduction #

**Note**: `extExtract.php` is a PHP script (in contrast to the rest of the suite). While special care has been taken to make the integration of `extExtract.php` as smooth as possible, the use of PHP has a few usability implications. Please see the **Known Problems** section at the end of this article for further details.

While `extExtract.php` is primarily designed to **extract** TYPO3 extension files (`.t3x`), it can also retrieve specific versions of an extension file from the TYPO3 extension repository.
This makes it especially helpful when trying to compare released TYPO3 extension file versions.

# Arguments #
```
$ ./extExtract.php --help
  Usage: ./extExtract.php [OPTIONS] [--extension=]EXTKEY

  Core:
  --help                  Display this help and exit.
  --update                Tries to update the script to the latest version.
  --base=PATH             The name of the base path where Typo3 is
                          installed. If no base is supplied, "typo3" is used.
  --export-config         Prints the default configuration of this script.
  --extract-config        Extracts configuration parameters from TYPO3.

  Options:
  --extension=EXTKEY      The extension key of the extension that should be
                          operated on.
  --force-version=VERSION Forces download of specific extension version.
  --dump                  Prints out a dump of the data structure of the
                          extension file.
  --extract               Forces the extraction process even if other commands
                          were invoked.
  --output-dir=DIRECTORY  The DIRECTORY to where the extension should be
                          extracted.

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
$ ./extExtract.php --base=myt3site --extension=news
```

## `--export-config` ##
Print the default configuration of the script to the standard output.

This allows for easy generation of a default config file, like so:
```
$ ./extExtract.php --export-config > typo3scripts.conf
```

## `--extract-config` ##
Tries to read the database-related parameters out of the TYPO3 configuration file.

This allows for easy generation of a base config file for other typo3scripts after you have completed your TYPO3 installation.
```
$ ./extExtract.php --extract-config > typo3scripts.conf
```

In case you're using a non-default TYPO3 installation directory, make sure to supply the `--base` parameter **before** the `--extract-config` parameter.
```
$ ./extExtract.php --base=myt3site --extract-config > typo3scripts.conf
```

## `--extension` / `EXTENSION` ##
Tells `extExtract.php` what TYPO3 extension should be extracted.
If the given string is a filename, the file will be extracted.
If the given string is an extension key, the given extension will be downloaded from the TYPO3 extension repository. See `--force-version` regarding what version will be downloaded.
```
$ ./extExtract.php --extension=news
```

## `--force-version` / `FORCE_VERSION` ##
Tells `extExtract.php` that the extension that should be retrieved, should be retrieved in a specific version. This obviously only makes sense when you're not trying to extract a local `.t3x` file.
If no version is given with `--force-version`, the version of the installed extension is used. If the extension is not installed, `extExtract.php` will fail.
```
$ ./extExtract.php --extension=news --force-version=1.2.3
```

## `--dump` / `DUMP` ##
Renders the data structure contained in the extension file. When using `--dump`, the extension is not extracted to the disk unless `--extract` is also specified.
```
$ ./extExtract.php --extension=news --dump
```

## `--string-limit` / `STRING_LIMIT` ##
String values in the extensions data structure will be summarized as `String[length]` if they are longer than this limit. The default is **60** characters. A limit of **0** means, no limit will be applied.
A string value will always be summarized if it contains non-printable characters.
```
$ ./extExtract.php --extension=news --dump --string-limit=100
```

## `--extract` / `EXTRACT` ##
When using `--dump` to print the data structure of an extension, `--extract` will ensure that the file contents are also extracted to disk.
```
$ ./extExtract.php --extension=news --dump --extract
```

## `--output-dir` / `OUTPUT_DIR` ##
The location where the extension should be extracted to. By default the extension filename with `-extracted` added at the end is used as the name for the folder where the extension is extracted to.
```
$ ./extExtract.php --extension=news --output-dir=/tmp
```

# Examples #

## Installation ##
```
/var/www$ cd t3site/
/var/www/t3site$ wget http://typo3scripts.googlecode.com/svn/trunk/extExtract.php
/var/www/t3site$ chmod 700 extExtract.php
```

## Determine local changes in extension ##
Sometime it is desireable to compare the local version of an extension against the one that is publically available in the TYPO3 extension repository.
This can easily be achieved with `extExtract.php`:
```
/var/www/t3site$ ./extExtract.php --extension=news
Sourcing script configuration from typo3scripts.conf...Done.
Update checking isn't yet implemented for 'extExtract.php'.
Retrieving original extension file for 'news' 1.3.1...Done.
Extracting file 'news_1.3.1.t3x.temp'...Done.
/var/www/t3site$ diff --recursive news_1.3.1.t3x.temp-extracted typo3/typo3conf/ext/news/
Only in typo3/typo3conf/ext/news: ext_emconf.php
```
In this case, the file `ext_emconf.php` was manipulated. Further use of `diff` could identify the changes on a file level.

## Retrieve specific version of extension ##
If you need the .t3x file for a given extension of a given version, you can easily do that with `extExtract.php` like so:
```
/var/www/t3site$ ./extExtract.php --extension=yag --force-version=1.0.0
Sourcing script configuration from typo3scripts.conf...Done.
Update checking isn't yet implemented for 'extExtract.php'.
Retrieving original extension file for 'yag' 1.0.0...Done.
Extracting file 'yag_1.0.0.t3x.temp'...Done.
```

# Known Issues #

## Bad interpreter ##
By default, `extExtract.php` will assume that the PHP command line interpreter (version 5.0+) is located at `/usr/bin/php`. If it is located somewhere else, you might get the following error message:
```
-bash: ./extExtract.php: /usr/bin/php: bad interpreter: No such file or directory
```
In this case, find `php` like this:
```
$ which php
/usr/local/bin/php
```
Now replace the interpreter on line 1 of `extExtract.php` with the value that `which` printed.

## Call to undefined function ##
By default, `extExtract.php` will assume that the PHP command line interpreter (version 5.0+) is located at `/usr/bin/php`. If the version located there is too low, some methods won't be available for use. This will result in error like:
```
<br />
<b>Fatal error</b>:  Call to undefined function:  file_put_contents() in <b>/users/hamburgler/websites/extExtract.php</b> on line <b>149</b><br />
```
If multiple versions of PHP are installed on your host, change the interpreter to match the location of your latest (5.0+) PHP installation.

## X-Powered-By headers in the shell ##
If you local PHP installation is running in CGI mode, you will see output like:
```
X-Powered-By: PHP/5.2.13
Content-type: text/html
```
To avoid this, adjust the interpreter to include the `-q` parameter, like so:
```
#!/usr/local/bin/php5 -q
```