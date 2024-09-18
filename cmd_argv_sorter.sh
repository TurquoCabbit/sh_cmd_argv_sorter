#!/bin/bash

read_argv_file() {
    local file=$1
    local -n ret=$2

    if [[ ! -f "$file" ]]; then
        echo "File:$file not found!"
        return 1
    fi

    ret=()
    while IFS= read -r line; do
        ret+=("$line")
    done < "$file"

    return 0
}

extract_field() {
    local field_str=$1
    local field_key=$2
    local -n ret_key=$3
    local -n ret_remain=$4

    ret_key=$(echo "$field_str" | sed -n "s/.*\(\b$field_key=[^ ]*\).*/\1/p")

    if [ ! -n "$ret_key" ]; then
        ret_remain="$field_str"
        return
    fi

    head=$(echo "$field_str" | sed -n "s/^\(.*\b$field_key=[^ ]*\).*/\1/p" | sed "s/$ret_key//" | sed 's/^ *//')

    tail=$(echo "$field_str" | sed -n "s/.*$ret_key\(.*\)/\1/p" | sed 's/^ *//')

    ret_remain="$head$tail"
}

array_to_dict() {
    local -n input_l=$1
    declare -n ret_d="$2"

    local field_keys_l=("${@:3}")
    local source_l=("${input_l[@]}")
    local dict_key=""

    for i in "${!source_l[@]}"; do

        dict_key=""
        for key in $(printf "%s\n" "${field_keys_l[@]}" | tac); do

            extract_field "${source_l[$i]}" "$key" key_field remain_str
            source_l[$i]=$remain_str

            if [ -n "$key_field" ]; then
                key_value=$(echo "$key_field" | grep -oP "(?<="$key"=)[^\s]*")
            else
                key_value="\0"
            fi

            dict_key="$key_value|$dict_key"
        done

        if [ -n "$dict_key" ]; then
            ret_d["$dict_key"]="${ret_d["$dict_key"]}|$remain_str"
        else
            ret_d["$dict_key"]=$remain_str
        fi
    done
}

get_diff_index() {
    local -n a1=$1
    local -n a2=$2
    local -n ret=$3
    
    for index in "${!a1[@]}"; do
        if [[ "${a1[$index]}" != "${a2[$index]}" ]]; then
            ret=$index
            return
        fi
    done
}

sort_array_by_item () {
    local -n input=$1
    local -n ret=$2
    local index=$3
    
    declare -A dict
    for i in "${input[@]}"; do
        IFS='|' read -r -a v_l <<< "$i"
        value=${v_l["$index"]}

        dict["$value"]+="$i&"
    done

    keys=("${!dict[@]}")

    if [[ ${#keys[@]} -eq 1 ]]; then
        ret=("${input[@]}")
        return
    fi

    if [[ ${keys[1]} =~ ^[0-9]+$ ]]; then
        sorted_keys=($(printf "%s\n" "${keys[@]}" | sort -n))
    else
        sorted_keys=($(printf "%s\n" "${keys[@]}" | sort))
    fi

    ret=()
    for i in "${sorted_keys[@]}"; do
        IFS='&'
        for j in ${dict["$i"]}; do
            if [ -n "$j" ]; then
                ret+=("$j")
            fi

        done
        unset IFS
    done
}

sort_and_make_table() {
    declare -n input_d="$1"

    local field_keys_l=("${@:2}")
    declare -A source_d
    local tbl=()
    local indent=""

    for i in "${!input_d[@]}"; do
        source_d[$i]="${input_d[$i]}"
    done

    dict_keys_l=("${!input_d[@]}")

    local len=${#field_keys_l[@]}
    local sorted_l=()
    for i in "${!field_keys_l[@]}"; do
        index=$((len-i-1))

        sort_array_by_item dict_keys_l sorted_l $index

        unset dict_keys_l
        dict_keys_l=("${sorted_l[@]}")
    done

    last_dict_keys=""
    for dict_keys in "${dict_keys_l[@]}"; do

        IFS='|' read -r -a values_l <<< "$dict_keys"
        
        if [ -n $last_dict_keys ]; then
            IFS='|' read -r -a last_dict_values_l <<< "$last_dict_keys"
        fi
        
        diff_index=0
        get_diff_index last_dict_values_l values_l diff_index

        j=0
        for value in "${values_l[@]}"; do

            curr_field_key=${field_keys_l[$j]}
            j=$((j+1))

            if [[ $diff_index -ge $j ]]; then
                indent="\t$indent"
                continue
            fi

            if [ "$value" != "\0" ]; then
                tbl+=("$indent-$curr_field_key=$value:")
            else
                tbl+=("$indent-$curr_field_key=none:")
            fi

            indent="\t$indent"
        done


        IFS='|' read -r -a lines <<< "${input_d["$dict_keys"]}"
        for line in "${lines[@]:1}"; do
            tbl+=("$indent$line")
        done
        
        indent=""
        last_dict_keys="$dict_keys"
    done

    for i in "${tbl[@]}"; do
		echo -e $i
    done 
}

parse_argv_file() {
    local fileName=$1
    local sort_keys="${@:2}"
    local argv_lines=()
    declare -A argv_dict

    if [[ $# -lt 2 ]]; then
        return
    fi

    read_argv_file $fileName argv_lines
    if [[ $? -ne 0 ]]; then
        echo "Sort file:$fileName fail"
        return
    fi

    array_to_dict argv_lines argv_dict $sort_keys

    sort_and_make_table argv_dict $sort_keys
}

parse_argv_file "${@:1}"

