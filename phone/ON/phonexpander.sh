#!/bin/bash

# Function to process .txt files in a given directory
process_txt_files() {
    local dir="$1"
    cd "$dir" || exit

    # Verify there are .txt files in the directory
    txt_files=(*.txt)
    if [ -z "${txt_files[0]}" ]; then
        echo "No .txt files found in directory: $dir"
        return
    fi

    # Pre-create directories for combinations 200-999
    for combo in {200..999}; do
        mkdir -p "$combo"
    done

    # Process each .txt file in the directory
    for input_file in *.txt; do
        echo "Processing file: $input_file in $dir"

        # Use sed to extract 4th-6th digits and write to appropriate file
        while IFS= read -r line; do
            if [[ "$line" =~ ^.{3}(.{3}) ]]; then
                combo="${BASH_REMATCH[1]}"
                # Append the line to the corresponding file in the folder
                echo "$line" >> "$combo/$combo.txt"
            fi
        done < "$input_file"
    done

    # Remove empty directories
    find . -type d -empty -delete

    # Notify user
    echo "All .txt files in $dir have been processed and numbers sorted into pre-created folders."
    cd - > /dev/null || exit
}

# Main loop: Iterate over each directory in the PWD
for dir in */; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        process_txt_files "$dir"
    fi
done

# Notify user
echo "All directories have been processed."

