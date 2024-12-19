#!/bin/bash

# Verify there are .txt files in the current directory
txt_files=(*.txt)
if [ -z "${txt_files[0]}" ]; then
    echo "No .txt files found in the current directory."
    exit 1
fi

# Pre-create directories for combinations 200-999
for combo in {200..999}; do
    mkdir -p "$combo"
done

# Process each .txt file in the current directory
for input_file in *.txt; do
    echo "Processing file: $input_file"
    
    # Use sed to extract 4th-6th digits and write to appropriate file
    while IFS= read -r line; do
        if [[ "$line" =~ ^.{3}(.{3}) ]]; then
            combo="${BASH_REMATCH[1]}"
            # Append the line to the corresponding file in the folder
            echo "$line" >> "$combo/$combo.txt"
        fi
    done < "$input_file"
done

# Notify user
echo "All .txt files have been processed and numbers sorted into pre-created folders."
