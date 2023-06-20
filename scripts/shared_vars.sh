#!/bin/sh

# Note: after sourcing this script, one should run `check_that_shared_vars_exist`

PYTHON_CMD="python3.8"
PIP_CMD="pip --require-virtualenv"

PROJ_NAME="CodeTalker_RealTime"
VENV_ENABLE_CMD="source ~/.virtualenvs/$PROJ_NAME/bin/activate"

inspect_and_verify_shared_vars() {
	shared_vars=("$PYTHON_CMD" "$PIP_CMD" "$PROJ_NAME" "$VENV_ENABLE_CMD")

	echo "--- here are the shared variables: ---"

	for shared_var in "$PYTHON_CMD" "$PIP_CMD" "$PROJ_NAME" "$VENV_ENABLE_CMD"; do
		if [[ $shared_var == "" ]]; then
			echo "a shared variable was not set! This may be dangerous, especially if it's a directory."
			exit 1
		fi

		echo $shared_var
	done

	echo "--------------------------------------"
}
