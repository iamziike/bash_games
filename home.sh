#!/usr/bin/env bash
#
# This is a script to serve as a home screen for the
# games selection.
#

# home screen variables
declare DEFAULT_SPRITE_COLOR="yellow";
# declare DEFAULT_BG_COLOR="black";

cd "$(dirname $(realpath $0))";
source "./helpers/index.sh";

# clean_up code
function clean_up() {
    reset_settings
    clear;
    exit 1;
}

function setup_game() {
    change_text_color yellow
    hide_input
    hide_cursor
}

function main() {
    local SNAKE_GAME="SNAKE GAME";
    local HANGMAN_GAME="HANGMAN";
    local choices_left=6;
    
    clear;
    while (( choices_left > 0))
    do
        go_prev_row && go_prev_row && go_prev_row && go_prev_row;
        change_text_color $DEFAULT_SPRITE_COLOR;
        center_text_horizontally_vertically "------------------------------------" 5
        center_text_horizontally_vertically "|            Hello Player          |" 4
        center_text_horizontally_vertically "------------------------------------" 3
        center_text_horizontally_vertically "Type q to quit" 2
        center_text_horizontally_vertically "Select a game you want to play" 0 1
        center_text_horizontally_vertically "  Type 1 for a $SNAKE_GAME" 0 3
        center_text_horizontally_vertically "Type 2 for a $HANGMAN_GAME" 0 4
        go_next_row
        
        # flush input buffer
        clear_input_buffer;
        
        read -r -n 1 game_choice
        
        if [[ $game_choice = "q" ]]
        then
            center_text_horizontally "CLOSING GAME"
            sleep 1;
            break;
        elif [[ $game_choice = 1 || $game_choice = 2 ]]
        then
            local file_source="./games/snake/snake_game.sh";
            choices_left=6;
            
            center_text_horizontally "Loading Choice...." clear;
            sleep 2;
            go_next_row;
            
            if [[ $game_choice = 1 ]]
            then
                center_text_horizontally "Opening the $SNAKE_GAME";
                center_text_horizontally "Please Wait...";
            elif [[ $game_choice = 2 ]]
            then
                center_text_horizontally "Opening the $HANGMAN_GAME";
                center_text_horizontally "Please Wait...";
                file_source="./games/hangman/hangman_game.sh";
            fi
            
            sleep 2;
            clear;
            
            source $file_source;
            clear;
            
            center_text_horizontally_vertically "Going Back to Home Screen";
            sleep 2;
            clear;
        else
            
            if (( choices_left == 6 ))
            then
                center_text_horizontally "Did not select a game" clear;
            elif (( choices_left == 5 ))
            then
                center_text_horizontally "You selected another wrong choice" clear;
            elif (( choices_left == 4 ))
            then
                center_text_horizontally "Why are you selecting a wrong choice" clear;
            elif (( choices_left == 3 ))
            then
                center_text_horizontally "Please stop that" clear;
            elif (( choices_left == 2 ))
            then
                center_text_horizontally "It seems like you don't want to play !!" clear;
            elif (( choices_left == 2 ))
            then
                center_text_horizontally "I will close the game !!" clear;
            else
                center_text_horizontally "Closing game !!" clear;
                sleep_random_btw 1 3;
                break;
            fi;
            
            choices_left=$(( choices_left - 1 ));
        fi
    done
}

# catch every control c
trap clean_up INT;

setup_game
main
clean_up;
