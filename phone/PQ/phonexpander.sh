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

    # Process each .txt file in the directory
    for input_file in *.txt; do
        echo "Processing file: $input_file in $dir"

        # Use sed to extract 4th-6th digits and write to appropriate file
        while IFS= read -r line; do
            if [[ "$line" =~ ^.{3}(.{3}) ]]; then
                combo="${BASH_REMATCH[1]}"
                # Append the line to the corresponding file directly in the directory
                echo "$line" >> "$combo.txt"
            fi
        done < "$input_file"

        # Rename the source .txt file to all.txt
        mv "$input_file" "all.txt"
    done

    # Remove empty directories
    find . -type d -empty -delete

    # Notify user
    echo "All .txt files in $dir have been processed and numbers sorted into files named by their 4th-6th digits."
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
