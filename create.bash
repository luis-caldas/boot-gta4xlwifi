#!/usr/bin/env bash

TAR_FILE_NAME="up_param.tar"
PICTURES_FOLDER="./pics"

FILE_BYTES="8388608"

function main() {

	echo "Boot image generator"

	# Check if given file exist
	if [ -z "${1}" ]; then echo "No file given"; return; fi
	if [ ! -f "${1}" ]; then echo "The file given does not exist"; return; fi

	# Get our current script dir
	cur_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

	echo "Creating output folder"

	# Create out and tmp dir path
	out_dir="${cur_dir}/out"
	tmp_dir="${cur_dir}/tmp"

	# Delete old file if exists
	if [ -e "${out_dir}" ]; then
		echo "Deleting old out"
		rm -r "${out_dir}"
	fi

	# Create output and temp
	mkdir -p "${out_dir}"
	mkdir -p "${tmp_dir}"

	# Create name variables
	main_logo_name="logo.jpg"
	tar_path="${out_dir}/${TAR_FILE_NAME}"

	# Copy given file to have the proper name
	logo_path="${tmp_dir}/${main_logo_name}"
	cp "${1}" "${logo_path}"

	# Copy all images
	cp "${PICTURES_FOLDER}/"*".jpg" "${tmp_dir}"

	echo "Stripping all pictures"

	# Strip all exif information
	for each_pic in "${tmp_dir}/"*".jpg"; do
		mogrify "${each_pic}" -interlace none
		exiftool -all= -overwrite_original "${each_pic}" &> /dev/null
	done

	echo "Adding images to TAR"

	# Archive
	cd "${tmp_dir}" || { echo "Unable to change directory"; exit; }
	tar cf "${tar_path}" -- *jpg

	echo "Tar file created"

	# Return current folder
	cd "${cur_dir}" || { echo "Unable to change directory"; exit; }

	# Bytes checking
	cur_bytes="$(stat --printf="%s" "${tar_path}")"

	echo "Cleaning up"

	# Cleanup
	rm -r "${tmp_dir}"

	# Check if file is different size
	if [ "$cur_bytes" -gt "$FILE_BYTES" ]; then
		rm "${tar_path}"
		echo "Error: File generated is too big, please fix the pictures"
		exit 1
	fi

	# Pad the rest of the file if needed
	if [ "$cur_bytes" -lt "$FILE_BYTES" ]; then
		truncate -s "${FILE_BYTES}" "${tar_path}"
	fi

	echo "Success"

}


main "${@}"