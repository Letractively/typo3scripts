#!/bin/bash

# Typo3 Version Switching Script
# written by Oliver Salzburg

set -o nounset
set -o errexit

SELF=$(basename "$0")

# Show the help for this script
function showHelp() {
  cat << EOF
  Usage: $0 [OPTIONS --version=<VERSION>]|<VERSION>
  
  Core:
  --help            Display this help and exit.
  --update          Tries to update the script to the latest version.
  --base=PATH       The name of the base path where Typo3 should be installed.
                    If no base is supplied, "typo3" is used.
  Options:
  --version=VERSION The version to switch to.
  
  Note: When using an external configuration file, it is sufficient to supply
        just the target version as a parameter.
        When supplying any other command line argument, supply the target
        version through the --version command line parameter.
EOF
  exit 0
}

# Check on minimal command line argument count
REQUIRED_ARGUMENT_COUNT=1
if [[ $# -lt $REQUIRED_ARGUMENT_COUNT ]]; then
  echo "Insufficient command line arguments!"
  echo "Use $0 --help to get additional information."
  exit -1
fi

# Script Configuration start
# The base directory where Typo3 is installed
BASE=typo3
# The version to switch to
VERSION=$1
# Script Configuration end

# The base location from where to retrieve new versions of this script
UPDATE_BASE=http://typo3scripts.googlecode.com/svn/trunk

# Self-update
function runSelfUpdate() {
  echo "Performing self-update..."
  
  # Download new version
  echo -n "Downloading latest version..."
  if ! wget --quiet --output-document="$0.tmp" $UPDATE_BASE/$SELF ; then
    echo "Failed: Error while trying to wget new version!"
    echo "File requested: $UPDATE_BASE/$SELF"
    exit 1
  fi
  echo "Done."
  
  # Copy over modes from old version
  OCTAL_MODE=$(stat -c '%a' $SELF)
  if ! chmod $OCTAL_MODE "$0.tmp" ; then
    echo "Failed: Error while trying to set mode on $0.tmp."
    exit 1
  fi
  
  # Spawn update script
  cat > updateScript.sh << EOF
#!/bin/bash
# Overwrite old file with new
if mv "$0.tmp" "$0"; then
  echo "Done. Update complete."
  rm -- \$0
else
  echo "Failed!"
fi
EOF
  
  echo -n "Inserting update process..."
  exec /bin/bash updateScript.sh
}

# Read external configuration
CONFIG_FILENAME=${SELF:0:${#SELF}-3}.conf
if [[ -e "$CONFIG_FILENAME" ]] && [[ "$1" != "--help" ]] && [[ "$1" != "-h" ]]; then
  echo -n "Sourcing script configuration from $CONFIG_FILENAME..."
  source $CONFIG_FILENAME
  echo "Done."
fi

# Read command line arguments (overwrites config file)
for option in $*; do
  case "$option" in
    --help|-h)
      showHelp
      ;;
    --update)
      runSelfUpdate
      ;;
    --base=*)
      BASE=$(echo $option | cut -d'=' -f2)
      ;;
    --version=*)
      VERSION=$(echo $option | cut -d'=' -f2)
      ;;
    *)
      VERSION=$option
      ;;
  esac
done

# Check for dependencies
function checkDependency() {
  if ! hash $1 2>&-; then
    echo "Failed!"
    echo "This script requires '$1' but it can not be found. Aborting." >&2
    exit 1
  fi
}
echo -n "Checking dependencies..."
checkDependency wget
checkDependency curl
checkDependency md5sum
checkDependency grep
checkDependency awk
checkDependency tar
echo "Succeeded."

# Update check
SUM_LATEST=$(curl $UPDATE_BASE/versions 2>&1 | grep $SELF | awk '{print $1}')
SUM_SELF=$(md5sum "$0" | awk '{print $1}')
if [[ "$SUM_LATEST" != "$SUM_SELF" ]]; then
  echo "NOTE: New version available!"
fi

# Begin main operation

VERSION_FILENAME=typo3_src-$VERSION.tar.gz
TYPO3_DOWNLOAD_URL=http://prdownloads.sourceforge.net/typo3/$VERSION_FILENAME
VERSION_FILE=$BASE/$VERSION_FILENAME
VERSION_DIRNAME=typo3_src-$VERSION
VERSION_DIR=$BASE/$VERSION_DIRNAME/
SYMLINK=$BASE/typo3_src

echo -n "Looking for Typo3 source package at $VERSION_DIR..."
if [[ -d "$VERSION_DIR" ]]; then
  echo "Found!"
else
  # Retrieve Typo3 source package
  if [[ -e "$VERSION_FILE" ]]; then
    echo "NOT found!"
    echo "Archive already exists. Trying to resume download."
    echo -n "Downloading $TYPO3_DOWNLOAD_URL..."
    if ! wget --quiet --continue $TYPO3_DOWNLOAD_URL --output-document=$VERSION_FILE; then
      echo "Failed!"
      exit 1
    fi
  else
    echo "NOT found! Downloading."
    echo -n "Downloading $TYPO3_DOWNLOAD_URL..."
    if ! wget --quiet $TYPO3_DOWNLOAD_URL --output-document=$VERSION_FILE; then
      echo "Failed!"
      exit 1
    fi
  fi
  echo "Done."

  echo -n "Extracting source package $VERSION_FILE..."
  if ! tar --extract --gzip --directory $BASE --file $VERSION_FILE; then
    echo "Failed!"
    exit 1
  fi
  echo "Done."
fi

# Switch symlink
echo -n "Switching Typo3 source symlink to $VERSION_DIR..."
if ! rm --force -- $SYMLINK; then
  echo "Failed! Unable to remove old symlink '$SYMLINK'"
  exit 1
fi
if ! ln --symbolic $VERSION_DIRNAME $SYMLINK; then
  echo "Failed! Unable to create new symlink '$SYMLINK'"
  exit 1
fi
echo "Done."

# Delete old, cached files
echo -n "Deleting temp_CACHED_* files from typo3conf..."
if ! rm --force -- $BASE/typo3conf/temp_CACHED_*; then
  echo "Failed!"
  # No need to exit. Failing to delete cache files is not critical to operation
fi

echo "Done!"
echo "Version switched to $VERSION."

# vim:ts=2:sw=2:expandtab: