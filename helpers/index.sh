#!/usr/bin/env bash

declare -x FALSE=1;
declare -x TRUE=0;

function is_helpers_file_sourced () {
    return 1;
}

function get_screen_width() {
    echo $(tput cols)
}

function get_screen_height() {
    echo $(tput lines)
}

function reset_settings() {
    tput reset
}

function get_screen_width_height() {
    w=get_screen_width;
    h=get_screen_height;
    size_arr=("$w" "$h");
    echo "${size_arr[@]}"
}

function erase_line() {
    tput el
}

function pause_cursor_movement() {
    # save cursor point ie does not move cursor after a write
    # unless explicity moved
    tput sc;
}

function unpause_cursor_movement() {
    tput rc
}

function hide_cursor() {
    tput civis
}

function unhide_cursor() {
    tput cnorm;
}

function hide_input() {
    stty -echo
}

function unhide_input() {
    stty echo
}

function change_text_color() {
    COLOR_NUM=$1;
    # Black: 0
    # Red: 1
    # Green: 2
    # Yellow: 3
    # Blue: 4
    # Magenta: 5
    # Cyan: 6
    # White: 7
    
    if [[ $COLOR_NUM = default || $COLOR_NUM = black || $COLOR_NUM = 0  ]]
    then
        tput setaf 0
    elif [[ $COLOR_NUM = red || $COLOR_NUM = 1 ]]
    then
        tput setaf 1
    elif [[ $COLOR_NUM = green || $COLOR_NUM = 2 ]]
    then
        tput setaf 2
    elif [[ $COLOR_NUM = yellow || $COLOR_NUM = 3 ]]
    then
        tput setaf 3
    elif [[ $COLOR_NUM = blue || $COLOR_NUM = 4 ]]
    then
        tput setaf 4
    elif [[ $COLOR_NUM = magenta || $COLOR_NUM = 5 ]]
    then
        tput setaf 5
    elif [[ $COLOR_NUM = cyan || $COLOR_NUM = 6 ]]
    then
        tput setaf 6
    elif [[ $COLOR_NUM = white || $COLOR_NUM = 7 ]]
    then
        tput setaf 7
    fi;
}

function change_text_bgcolor() {
    COLOR_NUM=$1;
    
    if [[ $COLOR_NUM = default || $COLOR_NUM = black || $COLOR_NUM = 0  ]]
    then
        tput setab 0
    elif [[ $COLOR_NUM = red || $COLOR_NUM = 1 ]]
    then
        tput setab 1
    elif [[ $COLOR_NUM = green || $COLOR_NUM = 2 ]]
    then
        tput setab 2
    elif [[ $COLOR_NUM = yellow || $COLOR_NUM = 3 ]]
    then
        tput setab 3
    elif [[ $COLOR_NUM = blue || $COLOR_NUM = 4 ]]
    then
        tput setab 4
    elif [[ $COLOR_NUM = magenta || $COLOR_NUM = 5 ]]
    then
        tput setab 5
    elif [[ $COLOR_NUM = cyan || $COLOR_NUM = 6 ]]
    then
        tput setab 6
    elif [[ $COLOR_NUM = white || $COLOR_NUM = 7 ]]
    then
        tput setab 7
    fi;
}

function go_prev_row() {
    tput cuu1
}

function go_next_row() {
    tput ind
}

function go_next_col() {
    tput cuf 1
}

function center_text_horizontally() {
    if [[ $2 = "clear" ]]
    then
        erase_line
    fi;
    
    text=$1;
    text_width=${#text};
    col=$((( $(get_screen_width) / 2 )  - text_width / 2 ));
    
    tput hpa $col
    echo "$text"
}

function center_text_horizontally_vertically() {
    if [[ $4 = "clear" ]]
    then
        erase_line
    fi;
    
    text=$1;
    text_width=${#text};
    steps_to_remove=${2:-0};
    steps_to_add=${3:-0};
    col=$((( $(get_screen_width) / 2 )  - text_width / 2 ));
    row=$(( (( $(get_screen_height) / 2 ) - steps_to_remove) + steps_to_add ));
    
    tput cup "$row" "$col";
    echo "$text"
}

function center_text_horizontally_vertically_of() {
    # Loop through each string in the array and check if it matches the pattern
    if [[ $4 = "clear" ]]
    then
        erase_line
    fi;
    
    text=$1;
    text_width=${#text};
    row=$(($2 / 2 ));
    col=$(($3 / 2 - text_width / 2));
    
    tput cup "$row" "$col";
    echo "$text"
}

function center_text_horizontally_of() {
    if [[ $2 = "clear" ]]
    then
        erase_line
    fi;
    
    text=$1;
    text_width=${#text};
    col=$((( $2 / 2 )  - text_width / 2 ));
    
    tput hpa $col
    echo "$text"
}


function dim_text() {
    # tput dim
    echo -e "\e[2m";
}

function undo_dim_text() {
    # tput rmso
    echo -e "\e[22m";
}

function undo_text_settings() {
    tput sgr0
}

# it can generate the min value or the max value beware
function get_random_btw() {
    local args=("$@")
    local min=$1;
    local max=$2;
    local excepts=("${args[@]:2}")
    local value;
    
    while true
    do
        value=$RANDOM;
        if ((value >= min && value < max))
        then
            local is_includes=false;
            for (( i=0; i<${#excepts[@]}; i++ ))
            do
                if [[ ${excepts[$i]} == "$value" ]]
                then
                    is_includes=true;
                    break;
                fi;
            done;
            
            if ! $is_includes
            then
                echo $value;
                break;
            fi;
        fi;
    done;
}

function sleep_random_btw() {
    sleep "$(get_random_btw "$1" "$2")";
}

function move_to_top() {
    tput cup 0 0;
}

function move_to() {
    row=$1;
    col=$2;
    tput cup "$row" "$col";
}

function move_to_nd_output() {
    row=$1;
    col=$2;
    text=$3;
    move_to "$row" "$col";
    echo -n "$text"
}

function clear_input_buffer() {
    # Clear input buffer
    read -t 0.005 -n 1000000000 discard
}

function display_comming_soon() {
    local COLOR=$1;
    local TEXT_1="   ____ ___  __  __ ___ _   _  ____    ____   ___   ___  _   _ "
    local TEXT_2="  / ___/ _ \|  \/  |_ _| \ | |/ ___|  / ___| / _ \ / _ \| \ | |"
    local TEXT_3=" | |  | | | | |\/| || ||  \| | |  _   \___ \| | | | | | |  \| |"
    local TEXT_4=" | |__| |_| | |  | || || |\  | |_| |   ___) | |_| | |_| | |\  |"
    local TEXT_5="  \____\___/|_|  |_|___|_| \_|\____|  |____/ \___/ \___/|_| \_|"
    
    change_text_color "$COLOR";
    center_text_horizontally_vertically "";
    go_prev_row && go_prev_row;
    center_text_horizontally "$TEXT_1";
    center_text_horizontally "$TEXT_2";
    center_text_horizontally "$TEXT_3";
    center_text_horizontally "$TEXT_4";
    center_text_horizontally "$TEXT_5";
}