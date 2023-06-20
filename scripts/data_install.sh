#!/bin/sh

##### A shared global constant, and a utility function

DATA_DEST="CodeTalker/vocaset"

wait_for_enter_key() {
	log_status "press ENTER once you have done so."
	read
}

##### Some installation functions

prepare_for_install() {
	source utils/utils.sh
	source utils/shared_vars.sh
	inspect_and_verify_shared_vars
	cd ..
}

get_flame_sample() {
	log_status "getting flame sample\n"

	filename="FLAME_sample.ply"
	try_cmd "curl -L https://raw.githubusercontent.com/TimoBolkart/voca/master/template/$filename --silent --output $filename"

	mv "$filename" "$DATA_DEST"
}

get_pretrained_models() {
	log_status "next, you will need to download these 2 pretrained models, and place them in the '$DATA_DEST' directory."
	log_status "link 1: https://drive.google.com/file/d/1RszIMsxcWX7WPlaODqJvax8M_dnCIzk5/view"
	log_status "link 2: https://drive.google.com/file/d/1phqJ_6AqTJmMdSq-__KY6eVwN4J9iCGP/view"
	wait_for_enter_key
}

get_voca_training_data() {
	log_status "next, you will need to download the VOCA training data, and place it in the '$DATA_DEST' directory."
	log_status "you will only need these files: data_verts.npy, raw_audio_fixed.pkl, templates.pkl, and subj_seq_to_idx.pkl."
	log_status "you can find them here: https://voca.is.tue.mpg.de/download.php, under 'VOCA, Training Data (8GB)'. (you may need to make an account first.)"
	wait_for_enter_key
}

check_that_all_files_are_there() {
	log_status "verifying existence of all needed files"

	needed_files=(
		"FLAME_sample.ply"

		"vocaset_stage1.pth.tar"
		"vocaset_stage2.pth.tar"

		"data_verts.npy"
		"raw_audio_fixed.pkl"
		"templates.pkl"
		"subj_seq_to_idx.pkl"
	)

	for file in "${needed_files[@]}"; do
		log_status "checking for existence of file '$file'"

		if [ ! -f "$file" ]; then
			echo "the file '$file' could not be found! cannot proceed with data installation."
			exit 1
		fi
	done
}

process_data() {
	log_status "processing data (this may take a minute)..."

	try_cmd "mkdir -p vertices_npy wav"
	try_cmd "$VENV_ENABLE_CMD"
	try_cmd "$PYTHON_CMD process_voca_data.py"
}

##### The main function

main() {
	prepare_for_install
	print_newline

	get_flame_sample

	get_pretrained_models
	get_voca_training_data

	cd "$DATA_DEST"
	check_that_all_files_are_there
	print_newline

	process_data
	log_status "done!"
}

main

#####
