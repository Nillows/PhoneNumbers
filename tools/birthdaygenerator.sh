#!/bin/bash

########################################
# Output file
########################################
output_file="date_wordlist.txt"
> "$output_file"

########################################
# Month Dictionaries
########################################
short_months=("jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct" "nov" "dec")
long_months=("january" "february" "march" "april" "may" "june" "july" "august" "september" "october" "november" "december")
cases=("lower" "capital" "upper")

########################################
# Predefined “Big Matrix” for Days (1..31)
########################################
declare -A day_cardinals day_ordinals
day_cardinals[1]="one";      day_ordinals[1]="first"
day_cardinals[2]="two";      day_ordinals[2]="second"
day_cardinals[3]="three";    day_ordinals[3]="third"
day_cardinals[4]="four";     day_ordinals[4]="fourth"
day_cardinals[5]="five";     day_ordinals[5]="fifth"
day_cardinals[6]="six";      day_ordinals[6]="sixth"
day_cardinals[7]="seven";    day_ordinals[7]="seventh"
day_cardinals[8]="eight";    day_ordinals[8]="eighth"
day_cardinals[9]="nine";     day_ordinals[9]="ninth"
day_cardinals[10]="ten";     day_ordinals[10]="tenth"
day_cardinals[11]="eleven";  day_ordinals[11]="eleventh"
day_cardinals[12]="twelve";  day_ordinals[12]="twelfth"
day_cardinals[13]="thirteen";  day_ordinals[13]="thirteenth"
day_cardinals[14]="fourteen";  day_ordinals[14]="fourteenth"
day_cardinals[15]="fifteen";   day_ordinals[15]="fifteenth"
day_cardinals[16]="sixteen";   day_ordinals[16]="sixteenth"
day_cardinals[17]="seventeen"; day_ordinals[17]="seventeenth"
day_cardinals[18]="eighteen";  day_ordinals[18]="eighteenth"
day_cardinals[19]="nineteen";  day_ordinals[19]="nineteenth"
day_cardinals[20]="twenty";    day_ordinals[20]="twentieth"
day_cardinals[21]="twentyone"; day_ordinals[21]="twentyfirst"
day_cardinals[22]="twentytwo"; day_ordinals[22]="twentysecond"
day_cardinals[23]="twentythree"; day_ordinals[23]="twentythird"
day_cardinals[24]="twentyfour"; day_ordinals[24]="twentyfourth"
day_cardinals[25]="twentyfive"; day_ordinals[25]="twentyfifth"
day_cardinals[26]="twentysix";  day_ordinals[26]="twentysixth"
day_cardinals[27]="twentyseven"; day_ordinals[27]="twentyseventh"
day_cardinals[28]="twentyeight"; day_ordinals[28]="twentyeighth"
day_cardinals[29]="twentynine";  day_ordinals[29]="twentyninth"
day_cardinals[30]="thirty";      day_ordinals[30]="thirtieth"
day_cardinals[31]="thirtyone";   day_ordinals[31]="thirtyfirst"

########################################
# Numeric suffix function
# e.g. 1 -> st, 2 -> nd, 3 -> rd, else th
########################################
numeric_suffix() {
    local d=$1
    if [[ $d -eq 1 || $d -eq 21 || $d -eq 31 ]]; then
        echo "st"
    elif [[ $d -eq 2 || $d -eq 22 ]]; then
        echo "nd"
    elif [[ $d -eq 3 || $d -eq 23 ]]; then
        echo "rd"
    else
        echo "th"
    fi
}

########################################
# Generate numeric day permutations:
# e.g. 1, 1st, 1ST, 01, 01st, 01ST
########################################
get_numeric_day_variants() {
    local d=$1
    local day2d=$(printf "%02d" "$d")
    local sfx=$(numeric_suffix "$d")

    local variants=()
    # Simple numeric (no leading zero)
    variants+=( "$d" )
    # e.g. "1st" (lower) and "1ST" (upper)
    variants+=( "${d}${sfx,,}" "${d}${sfx^^}" )

    # Leading-zero numeric
    variants+=( "$day2d" )
    # e.g. "01st" and "01ST"
    variants+=( "${day2d}${sfx,,}" "${day2d}${sfx^^}" )

    echo "${variants[@]}"
}

########################################
# Generate permutations for a single date (Y, M, D)
########################################
generate_permutations_for_date() {
    local year4=$1
    local month=$2
    local day=$3

    local year2=${year4:2:2}
    local day2d=$(printf "%02d" "$day")
    local month2d=$(printf "%02d" "$month")

    # Hard-coded cardinal & ordinal forms (words)
    local day_cardinal=${day_cardinals[$day]}
    local day_ordinal=${day_ordinals[$day]}
    [[ -z "$day_cardinal" || -z "$day_ordinal" ]] && return

    # Combine cardinal & ordinal word forms
    local day_word_variants=()
    for word in "$day_cardinal" "$day_ordinal"; do
        day_word_variants+=( "${word,,}" "${word^}" "${word^^}" )
    done

    # Numeric day variants with suffixes
    local numeric_variants=( $(get_numeric_day_variants "$day") )

    # We want all date orders: YMD, MDY, DMY
    # We'll output them for each letter case and separator.

    for case_type in "${cases[@]}"; do
        local m_short m_long
        case $case_type in
            "lower")
                m_short=${short_months[$((month - 1))],,}
                m_long=${long_months[$((month - 1))],,}
                ;;
            "capital")
                m_short=${short_months[$((month - 1))]^}
                m_long=${long_months[$((month - 1))]^}
                ;;
            "upper")
                m_short=${short_months[$((month - 1))]^^}
                m_long=${long_months[$((month - 1))]^^}
                ;;
        esac

        for sep in "" "/" "-" "."; do
            ###################################################
            # YMD permutations
            ###################################################
            for day_num in "${numeric_variants[@]}"; do
                echo "${year4}${sep}${month2d}${sep}${day_num}" >> "$output_file"
                echo "${year2}${sep}${month2d}${sep}${day_num}" >> "$output_file"
                echo "${year4}${sep}${m_short}${sep}${day_num}" >> "$output_file"
                echo "${year4}${sep}${m_long}${sep}${day_num}" >> "$output_file"
            done
            for dw in "${day_word_variants[@]}"; do
                echo "${year4}${sep}${month2d}${sep}${day2d}" >> "$output_file"
                echo "${year2}${sep}${month2d}${sep}${day2d}" >> "$output_file"
                echo "${year4}${sep}${m_short}${sep}${day2d}" >> "$output_file"
                echo "${year4}${sep}${m_long}${sep}${dw}" >> "$output_file"
            done

            ###################################################
            # MDY permutations
            ###################################################
            for day_num in "${numeric_variants[@]}"; do
                echo "${month2d}${sep}${day_num}${sep}${year4}" >> "$output_file"
                echo "${month2d}${sep}${day_num}${sep}${year2}" >> "$output_file"
                echo "${m_short}${sep}${day_num}${sep}${year4}" >> "$output_file"
                echo "${m_long}${sep}${day_num}${sep}${year4}" >> "$output_file"
            done
            for dw in "${day_word_variants[@]}"; do
                echo "${month2d}${sep}${day2d}${sep}${year4}" >> "$output_file"
                echo "${month2d}${sep}${day2d}${sep}${year2}" >> "$output_file"
                echo "${m_short}${sep}${day2d}${sep}${year4}" >> "$output_file"
                echo "${m_long}${sep}${dw}${sep}${year4}" >> "$output_file"
            done

            ###################################################
            # DMY permutations
            ###################################################
            for day_num in "${numeric_variants[@]}"; do
                echo "${day_num}${sep}${month2d}${sep}${year4}" >> "$output_file"
                echo "${day_num}${sep}${month2d}${sep}${year2}" >> "$output_file"
                echo "${day_num}${sep}${m_short}${sep}${year4}" >> "$output_file"
                echo "${day_num}${sep}${m_long}${sep}${year4}" >> "$output_file"
            done
            for dw in "${day_word_variants[@]}"; do
                echo "${day2d}${sep}${month2d}${sep}${year4}" >> "$output_file"
                echo "${day2d}${sep}${month2d}${sep}${year2}" >> "$output_file"
                echo "${day2d}${sep}${m_short}${sep}${year4}" >> "$output_file"
                echo "${dw}${sep}${m_long}${sep}${year4}" >> "$output_file"
            done
        done
    done
}

########################################
# Main Loop: Generate permutations
########################################
for year in {1900..2050}; do
    for month in {1..12}; do
        for day in {1..31}; do
            # Only process if the date is valid (avoid Feb 30, etc.)
            if date -d "$year-$(printf "%02d" "$month")-$(printf "%02d" "$day")" &>/dev/null; then
                generate_permutations_for_date "$year" "$month" "$day"
            fi
        done
    done
done

sort -u -o "$output_file" "$output_file"
echo "Comprehensive date wordlist generated in $output_file"

