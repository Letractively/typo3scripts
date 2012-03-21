#!/bin/bash

# TYPO3 Installation Backup Script
# written by Oliver Salzburg

set -o nounset
set -o errexit

SELF=$(basename "$0")

# Show the help for this script
function showHelp() {
  cat << EOF
  Usage: $0 [OPTIONS]
  
  Core:
  --help              Display this help and exit.
  --verbose           Display more detailed messages.
  --quiet             Do not display anything.
  --force             Perform actions that would otherwise abort the script.
  --update            Tries to update the script to the latest version.
  --update-check      Checks if a newer version of the script is available.
  --export-config     Prints the default configuration of this script.
  --extract-config    Extracts configuration parameters from TYPO3.
  --base=PATH         The name of the base path where TYPO3 is 
                      installed. If no base is supplied, "typo3" is used.
  
  Database:
  --hostname=HOST     The name of the host where the TYPO3 database is running.
  --username=USER     The username to use when connecting to the TYPO3
                      database.
  --password=PASSWORD The password to use when connecting to the TYPO3
                      database.
  --database=DB       The name of the database in which TYPO3 is stored.
EOF
}

# Print the default configuration to ease creation of a config file.
function exportConfig() {
  # Spaces are escaped here to avoid sed matching this line when exporting the
  # configuration
  sed -n "/#\ Script\ Configuration\ start/,/# Script Configuration end/p" "$0"
}

# Extract all known (database related) parameters from the TYPO3 configuration.
function extractConfig() {
  LOCALCONF="$BASE/typo3conf/localconf.php"
  
  echo HOST=$(tac $LOCALCONF | grep --perl-regexp --only-matching "(?<=typo_db_host = ')[^']*(?=';)")
  echo USER=$(tac $LOCALCONF | grep --perl-regexp --only-matching "(?<=typo_db_username = ')[^']*(?=';)")
  echo PASS=$(tac $LOCALCONF | grep --perl-regexp --only-matching "(?<=typo_db_password = ')[^']*(?=';)")
  echo DB=$(tac $LOCALCONF | grep --perl-regexp --only-matching "(?<=typo_db = ')[^']*(?=';)")
}

# Check on minimal command line argument count
REQUIRED_ARGUMENT_COUNT=0
if [[ $# -lt $REQUIRED_ARGUMENT_COUNT ]]; then
  echo "Insufficient command line arguments!" >&2
  echo "Use $0 --help to get additional information." >&2
  exit 1
fi

# Script Configuration start
# Should the script give more detailed feedback?
VERBOSE=false
# Should the script surpress all feedback?
QUIET=false
# Should the script ignore reasons that would otherwise cause it to abort?
FORCE=false
# The base directory where TYPO3 is installed
BASE=typo3
# The hostname of the MySQL server that TYPO3 uses
HOST=localhost
# The username used to connect to that MySQL server
USER=*username*
# The password for that user
PASS=*password*
# The name of the database in which TYPO3 is stored
DB=typo3
# Script Configuration end

# The base location from where to retrieve new versions of this script
UPDATE_BASE=http://typo3scripts.googlecode.com/svn/trunk

# Update check
function updateCheck() {
  if ! hash curl 2>&-; then
    consoleWriteLine "Update checking requires curl. Check skipped." >&2
    return 2
  fi
  
  SUM_LATEST=$(curl $UPDATE_BASE/versions 2>&1 | grep $SELF | awk '{print $2}')
  SUM_SELF=$(tail --lines=+2 "$0" | md5sum | awk '{print $1}')
  
  $VERBOSE && echo "Remote hash source: '$UPDATE_BASE/versions'" >&2
  $VERBOSE && echo "Own hash: '$SUM_SELF' Remote hash: '$SUM_LATEST'" >&2
  
  if [[ "" == $SUM_LATEST ]]; then
    echo "No update information is available for '$SELF'" >&2
    echo "Please check the project home page 'http://code.google.com/p/typo3scripts/'." >&2
    return 2
    
  elif [[ "$SUM_LATEST" != "$SUM_SELF" ]]; then
    echo "NOTE: New version available!" >&2
    return 1
  fi
  
  return 0
}

# Self-update
function runSelfUpdate() {
  echo "Performing self-update..."
  
  _tempFileName="$0.tmp"
  _payloadName="$0.payload"
  
  # Download new version
  echo -n "Downloading latest version..."
  if ! wget --quiet --output-document="$_payloadName" $UPDATE_BASE/$SELF ; then
    echo "Failed: Error while trying to wget new version!"
    echo "File requested: $UPDATE_BASE/$SELF"
    exit 1
  fi
  echo "Done."
  
  # Restore shebang
  _interpreter=$(head --lines=1 "$0")
  echo $_interpreter > "$_tempFileName"
  tail --lines=+2 "$_payloadName" >> "$_tempFileName"
  rm "$_payloadName"
  
  # Copy over modes from old version
  OCTAL_MODE=$(stat -c '%a' $SELF)
  if ! chmod $OCTAL_MODE "$_tempFileName" ; then
    echo "Failed: Error while trying to set mode on $_tempFileName."
    exit 1
  fi
  
  # Spawn update script
  cat > updateScript.sh << EOF
#!/bin/bash
# Overwrite old file with new
if mv "$_tempFileName" "$0"; then
  echo "Done."
  echo "Update complete."
  rm -- \$0
else
  echo "Failed!"
fi
EOF
  
  echo -n "Inserting update process..."
  exec /bin/bash updateScript.sh
}

# Make a quick run through the command line arguments to see if the user wants
# to print the help. This saves us a lot of headache with respecting the order
# in which configuration parameters have to be overwritten.
for option in $*; do
  case "$option" in
    --help|-h)
      showHelp
      exit 0
      ;;
  esac
done

# Read external configuration - Stage 1 - typo3scripts.conf (overwrites default, hard-coded configuration)
BASE_CONFIG_FILENAME="typo3scripts.conf"
if [[ -e "$BASE_CONFIG_FILENAME" ]]; then
  $VERBOSE && echo -n "Sourcing script configuration from $BASE_CONFIG_FILENAME..." >&2
  source $BASE_CONFIG_FILENAME
  $VERBOSE && echo "Done." >&2
fi

# Read external configuration - Stage 2 - script-specific (overwrites default, hard-coded configuration)
CONFIG_FILENAME=${SELF:0:${#SELF}-3}.conf
if [[ -e "$CONFIG_FILENAME" ]]; then
  $VERBOSE && echo -n "Sourcing script configuration from $CONFIG_FILENAME..." >&2
  source $CONFIG_FILENAME
  $VERBOSE && echo "Done." >&2
fi

# Read command line arguments (overwrites config file)
for option in $*; do
  case "$option" in
    --verbose)
      VERBOSE=true
      ;;
    --quiet)
      QUIET=true
      ;;
    --force)
      FORCE=true
      ;;
    --update)
      runSelfUpdate
      ;;
    --update-check)
      updateCheck
      exit $?
      ;;
    --export-config)
      exportConfig
      exit 0
      ;;
    --extract-config)
      extractConfig
      exit 0
      ;;
    --base=*)
      BASE=$(echo $option | cut -d'=' -f2)
      ;;
    --hostname=*)
      HOST=$(echo $option | cut -d'=' -f2)
      ;;
    --username=*)
      USER=$(echo $option | cut -d'=' -f2)
      ;;
    --password=*)
      PASS=$(echo $option | cut -d'=' -f2)
      ;;
    --database=*)
      DB=$(echo $option | cut -d'=' -f2)
      ;;
    *)
      echo "Unrecognized option \"$option\""
      exit 1
      ;;
  esac
done

# Check for dependencies
function checkDependency() {
  $VERBOSE && echo -n "Checking dependency '$1' => " >&2
  if ! hash $1 2>&-; then
    echo "Failed!" >&2
    echo "This script requires '$1' but it can not be found. Aborting." >&2
    exit 1
  fi
  $VERBOSE && echo $(which $1) >&2
  return 0
}
echo -n "Checking dependencies..." >&2
$VERBOSE && echo >&2
checkDependency wget
checkDependency curl
checkDependency md5sum
checkDependency grep
checkDependency awk
checkDependency tar
checkDependency mysqldump
echo "Succeeded." >&2

# Begin main operation

# Does the base directory exist?
if [[ ! -d $BASE ]]; then
  echo "The base directory '$BASE' does not seem to exist!" >&2
  exit 1
fi
# Is the base directory readable?
if [[ ! -r $BASE ]]; then
  echo "The base directory '$BASE' is not readable!" >&2
  exit 1
fi

# Filename for snapshot
FILE=$BASE-$(date +%Y-%m-%d-%H-%M).tgz

echo "Creating TYPO3 backup '$FILE'..." >&2

# Create database dump
echo -n "Creating database dump at '$BASE/database.sql'..." >&2
set +e errexit
_errorMessage=$(mysqldump --host=$HOST --user=$USER --password=$PASS --add-drop-table --add-drop-database --databases $DB 2>&1 > $BASE/database.sql)
_status=$?
set -e errexit
if [[ 0 < $_status ]]; then
  echo "Failed!" >&2
  echo "Error: $_errorMessage" >&2
  exit 1
fi
echo "Done." >&2


# Create backup archive
_statusMessage="Compressing TYPO3 installation..."
echo -n $_statusMessage >&2
if hash pv 2>&- && hash gzip 2>&- && hash du 2>&-; then
  echo "" >&2
  _folderSize=`du --summarize --bytes $BASE | cut --fields 1`
  if ! tar --create --file - $BASE | pv --progress --rate --bytes --size $_folderSize | gzip --best > $FILE; then
    echo "Failed!" >&2
    exit 1
  fi
  # Clear pv output and position cursor after status message
  # If stderr was redirected from the console, this messes up the prompt.
  # It's unfortunate, but ignored for the time being
  tput cuu 2 && tput cuf ${#_statusMessage} && tput ed
else
  if ! tar --create --gzip --file $FILE $BASE; then
    echo "Failed!" >&2
    exit 1
  fi
fi

echo "Done." >&2

# Now that the database dump is packed up, delete it
$VERBOSE && echo -n "Deleting database dump..." >&2
rm --force -- $BASE/database.sql
$VERBOSE && echo "Done!" >&2

# vim:ts=2:sw=2:expandtab:
