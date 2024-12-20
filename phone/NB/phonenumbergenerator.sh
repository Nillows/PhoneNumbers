#!/bin/bash

# Government info:
# https://cnac.ca/co_codes/co_code_status.htm
# https://www.allareacodes.com/canadian_area_codes.htm


###


# Define the array of area codes
# EXAMPLE area_codes=(123 234 345 456 567 678 789 890)
area_codes=(428 506)

# Define the array of special use numbers
# these are universal to north america, but edit as needed
special_use_numbers=(211 311 411 511 555 611 711 811 911 950 976)

# Intermediate output file (no area codes, just the last 7 digits)
base_numbers_file="base_numbers.txt"

# Remove the base numbers file if it exists to start fresh
[ -f "$base_numbers_file" ] && rm "$base_numbers_file"

# Function to check if a prefix matches any area code or special use number
is_prefix_match() {
  local prefix=$1
  # Check against area codes
  for code in "${area_codes[@]}"; do
    if [[ "$prefix" == "$code" ]]; then
      return 0
    fi
  done

  # Check against special use numbers
  for special in "${special_use_numbers[@]}"; do
    if [[ "$prefix" == "$special" ]]; then
      return 0
    fi
  done

  return 1
}

# PHASE 1: Generate the base list of 7-digit numbers (2,000,000 to 9,999,999) skipping invalid prefixes
number=2000000
while [[ $number -le 9999999 ]]; do
  prefix=${number:0:3}  # First 3 digits of the 7-digit number
  if is_prefix_match "$prefix"; then
    # If prefix matches any area code or special use, skip ahead by 10,000
    number=$((number + 10000))
    continue
  fi

  # Otherwise, record the number and increment by 1
  echo "$number" >> "$base_numbers_file"
  number=$((number + 1))
done

echo "Base 7-digit numbers generated in $base_numbers_file."

# PHASE 2: For each area code, prepend it to each base number and output to a separate file
for area_code in "${area_codes[@]}"; do
  output_file="${area_code}.txt"
  # Remove if exists
  [ -f "$output_file" ] && rm "$output_file"

  while read -r base_num; do
    echo "${area_code}${base_num}" >> "$output_file"
  done < "$base_numbers_file"

  echo "Numbers for area code $area_code generated in $output_file."
done

# Remove the base numbers file as it is no longer needed
rm "$base_numbers_file"
echo "Removed $base_numbers_file."
