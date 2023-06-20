#!/bin/sh

# No params
print_newline() {
	echo ""
}

# Param: cmd
try_cmd() {
	eval $1

	if [[ $? != 0 ]]; then
		echo "this command failed: '$1'"
		exit 1
	fi
}

# Param: status
log_status() {
	echo ">>> $1"
}

# Params: filename, src pattern, dest pattern
replace_in_file() {
	try_cmd "sed -i '' 's/$2/$3/g' $1"
}
