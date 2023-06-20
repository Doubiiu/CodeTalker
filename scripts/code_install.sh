#!/bin/sh

##### Some installation functions

prepare_for_install() {
	source utils/utils.sh
	source utils/shared_vars.sh
	inspect_and_verify_shared_vars
	cd ..
}

replace_old_venv() {
	log_status "note: a venv is a python virtual environment that holds a set of dependencies for a given project."

	install_dir="$PWD"
	mkdir -p ~/.virtualenvs

	cd ~/.virtualenvs
		log_status "navigated to venv dir $PWD"
		[ -d $PROJ_NAME ] && (log_status "removing a preexisting $PROJ_NAME venv"; rm -r $PROJ_NAME)
		log_status "making a new $PROJ_NAME venv"

		# TODO: add the `--copies` flag back?
		try_cmd "$PYTHON_CMD -m venv $PROJ_NAME"
	cd $install_dir

	log_status "renavigated to install dir $install_dir"
}

enable_curr_venv() {
	log_status "enabling the new $PROJ_NAME venv"
	try_cmd "$VENV_ENABLE_CMD"
}

install_brew_dependencies() {
	log_status "installing brew dependencies"
	try_cmd "brew install boost@1.82 ffmpeg"
}

install_pip_dependencies() {
	log_status "installing pip dependencies"

	cd CodeTalker
		try_cmd "$PIP_CMD install -r requirements.txt"
		log_status "patching numpy deprecation error"
		replace_in_file ~/.virtualenvs/$PROJ_NAME/lib/$PYTHON_CMD/site-packages/librosa/core/constantq.py "np.complex," "complex,"
	cd ..
}

install_mesh_library() {
	log_status "installing mesh library"

	cd CodeTalker
		new_mesh_lib_name="mesh_library"

		[ -d "$new_mesh_lib_name" ] && (log_status "removing preexisting mesh library code"; rm -r "$new_mesh_lib_name")

		log_status "getting mesh library code from github"
		try_cmd "git clone https://github.com/MPI-IS/mesh"
		mv mesh "$new_mesh_lib_name"

		cd "$new_mesh_lib_name"
			log_status "patching the mesh library's makefile and requirements.txt"
			replace_in_file Makefile python "$PYTHON_CMD"
			replace_in_file Makefile pip "$PIP_CMD"
			replace_in_file requirements.txt pyopengl "pyopengl==3.1.0"

			# TODO: perhaps limit what's built (everything may not be needed)
			log_status "running makefile for mesh library"
			BOOST_INCLUDE_DIRS=/usr/local/include make all
		cd ..
	cd ..
}

##### The main function

main() {
	prepare_for_install
	print_newline

	replace_old_venv
	enable_curr_venv
	print_newline

	install_brew_dependencies
	print_newline

	install_pip_dependencies
	print_newline

	install_mesh_library
	print_newline

	log_status "done!"
}

main

#####
