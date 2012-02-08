#!/bin/bash
set -o nounset
set -o errexit

INPUT=$1
# The index of the byte in the input file that is currently being processed
INDEX=0
# The current object nesting depth
DEPTH=0
# The type currently being parsed
TYPE="<unknown>"
# The Name register
NAME="<unnamed>"
# The Value register
VALUE="<undefined>"

REGISTER0=

function parse() {
        local _type=$(dd skip=$INDEX count=1 bs=1 if=$INPUT 2>/dev/null)
	case "$_type" in
		i)
			(( INDEX += 2 ))
			#echo -n "Integer"
			TYPE="Integer"
			parseInt
			;;
		d)
			(( INDEX += 2 ))
			echo "Float (not implemented)"
			exit 1
			;;
		b)
			(( INDEX += 2 ))
			echo "Boolean (not implemented)"
			exit 1
			;;
		s)
			(( INDEX += 2 ))
			#echo -n "String"
			TYPE="String"
			parseString
			;;
		a)
			(( INDEX += 2 ))
			#echo -n "Array"
			TYPE="Array"
			parseArray
			;;
		O)
			(( INDEX += 2 ))
			echo "Object (not implemented)"
			exit 1
			;;
		N)
			(( INDEX += 2 ))
			#echo -n "Null"
			TYPE="Null"
			;;
		*)
			echo "Unknown type '$_type' at index '$INDEX'" >&2
			exit 1
			;;
	esac
}

function readLength() {
	local _length=
	while true; do
		local _byte=$(dd skip=$INDEX count=1 bs=1 if=$INPUT 2>/dev/null)
		(( INDEX++ ))
		if [[ "$_byte" == ":" ]]; then
			(( INDEX++ ))
			REGISTER0=$_length
			return 0
		else
			_length=$_length$_byte
		fi
	done
}

_lengthStack=
_elementStack=
function parseArray() {
	# We need to go deeper!
	if [[ -n "${_arrayLength+x}" ]]; then
		_lengthStack=("${_lengthStack[@]}" "$_arrayLength")
	fi

	readLength
	local _arrayLength=$REGISTER0
	REGISTER0=

	# Output
	for (( i=0; i<$DEPTH; i++ )); do
		echo -n "  "
	done
	echo "$NAME ($TYPE[$_arrayLength])="

	for (( _arrayElement=0; _arrayElement<$_arrayLength; ++_arrayElement )); do
		#echo -n "[$_arrayElement]"
		(( ++DEPTH ))
		_elementStack=("${_elementStack[@]}" "$_arrayElement")

		parse
		NAME=$REGISTER0
		REGISTER0=
		parse
		VALUE=$REGISTER0
		REGISTER0=

		_stackElementIndex=$(expr ${#_elementStack[@]} - 1)
		_arrayElement=${_elementStack[$_stackElementIndex]}
		unset _elementStack[$_stackElementIndex]
		#_elementStack=("${_elementStack}")

		# Output
		if [[ $VALUE != "array" ]]; then
			for (( i=0; i<$DEPTH; i++ )); do
				echo -n "  "
			done
			echo "$NAME ($TYPE)=$VALUE"
		fi

		(( --DEPTH )) || true
	done

	# Aaaand we're back
	_stackElementIndex=$(expr ${#_lengthStack[@]} - 1)
	_arrayLength=${_lengthStack[$_stackElementIndex]}
	unset _lengthStack[$_stackElementIndex]
	_lengthStack=("${_lengthStack}")

	(( ++INDEX ))
	REGISTER0=array
}

function parseString() {
        readLength
        local _stringLength=$REGISTER0
	REGISTER0=


	local _utfStringLength=0
	local _byteCount=0
        #local _string=
        while [[ $_byteCount -lt $_stringLength ]]; do
		local _byte=$(dd skip=$((INDEX+$_utfStringLength)) count=1 bs=1 if=$INPUT 2>/dev/null)
                (( ++_utfStringLength ))
		local _byteValue=$(echo -n "$_byte" | od -A n -t d1)
		#echo "$_byteValue"
		if [[ 0 -le "$_byteValue" && "$_byteValue" -le "127" ]]; then
			(( ++_byteCount ))
		else
			(( _byteCount += 3 ))
		fi

        done

	#echo -n "[$_stringLength]"
	echo -n "[$_utfStringLength]"
	local _string=$(dd skip=$INDEX count=$_utfStringLength bs=1 if=$INPUT 2>/dev/null)
	#echo -n " = "
	#echo $_string
	REGISTER0=$_string
	INDEX=$(($INDEX+$_utfStringLength+2))
}

function parseInt() {
        local _number=
        while true; do
                local _byte=$(dd skip=$INDEX count=1 bs=1 if=$INPUT 2>/dev/null)
                (( INDEX++ ))
		if [[ "$_byte" == ";" ]]; then
			REGISTER0=$_number
			return 0
		else
	                _number=$_number$_byte
                fi
        done
}

parse
