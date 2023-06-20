#!/bin/sh

main() {
	source utils/shared_vars.sh
	source utils/utils.sh
	inspect_and_verify_shared_vars

	export PYTHONPATH=./
	cd ../CodeTalker
	# export PYTORCH_ENABLE_MPS_FALLBACK=1

	log_status "The output file will be located in CodeTalker/demo/output."
	log_status "Starting the demo...\n"
	try_cmd "$VENV_ENABLE_CMD"
	try_cmd "$PYTHON_CMD main/demo.py --config config/vocaset/demo.yaml"
}

main
