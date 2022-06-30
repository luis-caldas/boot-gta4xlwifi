#!/usr/bin/env bash

TAR_FILE_NAME="up_param.tar"
NEW_FOLDER="./pics"

FILE_BYTES="8388608"

# Function to get real script dir
function get_folder() {

	# get the folder in which the script is located
	SOURCE="${BASH_SOURCE[0]}"

	# resolve $SOURCE until the file is no longer a symlink
	while [ -h "$SOURCE" ]; do

	  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

	  SOURCE="$(readlink "$SOURCE")"

	  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"

	done

	# the final assignment of the directory
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

	# return the directory
	echo "$DIR"
}

function main() {

	echo "Boot image generator"

	# Check if given file exist
	if [ -z "${1}" ]; then echo "No file given"; return; fi
	if [ ! -f "${1}" ]; then echo "The file given does not exist"; return; fi

	# Get our current script dir
	cur_dir="$(get_folder)"

	echo "Creating output folder"

	# Create out dir path
	out_dir="${cur_dir}/out"

	# Delete old file if exists
	if [ -e "${out_dir}" ]; then
		echo "Deleting old files"
		rm -r "${out_dir}"
	fi

	# Create output folder
	mkdir -p "${out_dir}"

	echo "Adding images to TAR"

	# Create name variables
	main_logo_name="logo.jpg"
	tar_path="${out_dir}/${TAR_FILE_NAME}"

	# Copy given file to have the proper name
	logo_path="${NEW_FOLDER}/${main_logo_name}"
	cp "${1}" "${logo_path}"

	# Archive
	cd "${NEW_FOLDER}" || { echo "Unable to change directory"; exit; }
	tar cf "${tar_path}" -- *jpg

	echo "Tar file created"

	# Return current folder
	cd "${cur_dir}" || { echo "Unable to change directory"; exit; }

	# Bytes checking
	cur_bytes="$(stat --printf="%s" "${tar_path}")"

	# Cleanup
	rm "${logo_path}"

	# Check if file is different size
	if [ "$cur_bytes" -gt "$FILE_BYTES" ]; then
		rm "${tar_path}"
		echo "Error: File generated is too big, please fix the pictures"
		exit 1
	fi

	# Pad the rest of the file if needed
	if [ "$cur_bytes" -lt "$FILE_BYTES" ]; then
		difference=$(( FILE_BYTES - cur_bytes ))
		truncate -s "${FILE_BYTES}" "${tar_path}"
	fi

	echo "Success"

}


main "${@}"