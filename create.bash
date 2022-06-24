#!/usr/bin/env bash

TAR_FILE_NAME="up_param"
NEW_FOLDER="./pics/new/"

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

	# Create output folder
	out_dir="${cur_dir}/out"
	mkdir -p "${out_dir}"

    echo "Adding images to TAR"

    # Add all images to the tar file
    tar_path="${out_dir}/${TAR_FILE_NAME}."
	7z a -ttar "${tar_path}" "${NEW_FOLDER}/"*jpg &> /dev/null
	7z a -ttar "${tar_path}" "${1}" &> /dev/null

	echo "Tar file created"

	echo "Success"

}


main "${@}"