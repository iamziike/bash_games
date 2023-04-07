#!/usr/bin/env bash

# misc
declare -i MIN_ROW=2;
declare -i MIN_COLUMN=0;
declare -i MAX_ROW=$(( $(get_screen_height) - 4 ));
declare -i MAX_COLUMN=$(( $(get_screen_width) / 2  ));

declare DEFAULT_SPRITE_COLOR="yellow";
declare DEFAULT_BG_COLOR="black";

# fruit variables
declare fruit_positions=();
declare is_fruit_on_screen=false;

# snake variables
declare RIGHT=RIGHT;
declare LEFT=LEFT;
declare TOP=TOP;
declare BOTTOM=BOTTOM;
declare -i snake_speed_x=2;
declare -i snake_speed_y=1;
declare snake_head_design="◼";
declare snake_body_design="▧";
declare snake_positions=();
declare snake_current_direction=$RIGHT;
declare is_increase_snake_size=false;

# game variables
declare -i score=0;
declare is_first_time=true;

# fruit functions
function handle_fruit_generate() {
    local row;
    local column=1;
    local snake_rows_occupied=();
    local snake_columns_occupied=();
    
    is_fruit_on_screen=true;
    
    change_text_color $DEFAULT_SPRITE_COLOR;
    change_text_bgcolor $DEFAULT_BG_COLOR;
    
    for (( i=0; i<${#snake_positions[@]}; i+=2))
    do
        snake_rows_occupied=(snake_positions[$i] ${snake_rows_occupied[@]});
        snake_columns_occupied=(snake_positions[$((i+1))] ${snake_columns_occupied[@]});
    done;
    
    row=$(get_random_btw $((MIN_ROW + 1)) $MAX_ROW "${snake_rows_occupied[@]}");
    
    while (( column % 2 != 0 ))
    do
        column=$(get_random_btw $((MIN_COLUMN + 1)) $((MAX_COLUMN - 1)) "${snake_columns_occupied[@]}");
    done;
    
    fruit_positions=("$row" "$column");
}

function handle_fruit_render() {
    function get_random_fruit_type() {
        local fruit_types=(🍇 🍈 🍉 🍊 🍋 🍌 🍍 🥭 🍎 🍏 🍐 🍒 🍓 🥝 🍅 🥥 🥑 🥔 🥕 🌶️ 🥦 🧄 🧅 );
        local random_index;
        
        random_index=$(get_random_btw 0 ${#fruit_types[@]});
        echo -ne "${fruit_types[$random_index]}";
    }
    
    move_to_nd_output "${fruit_positions[0]}" "${fruit_positions[1]}" "$(get_random_fruit_type)";
}

# snake functions
function handle_snake_movement() {
    local snake_current_row="${snake_positions[0]}";
    local snake_current_column="${snake_positions[1]}";
    
    # flush input buffer
    clear_input_buffer;
    
    read -rsn 3 -t 0.5 input;
    
    if [[ ($input == $'\x1b[A' && $snake_current_direction != "$BOTTOM") || ($snake_current_direction == "$TOP" && (${#input} -lt 1 || $input == $'\x1b[B' || ! $input =~ "[D"|"[C" )) ]]
    then
        snake_current_row=$(( snake_current_row - snake_speed_y ));
        snake_current_direction=$TOP;
    elif [[ ($input == $'\x1b[B' && $snake_current_direction != "$TOP") || ($snake_current_direction == "$BOTTOM" && (${#input} -lt 1 || $input == $'\x1b[A' || ! $input =~ "[D"|"[C" )) ]]
    then
        snake_current_row=$(( snake_current_row + snake_speed_y ));
        snake_current_direction=$BOTTOM;
    elif [[ ($input == $'\x1b[C' && $snake_current_direction != "$LEFT") || ($snake_current_direction == "$RIGHT" && (${#input} -lt 1 || $input == $'\x1b[D' || ! $input =~ "[A"|"[B" )) ]]
    then
        snake_current_column=$(( snake_current_column + snake_speed_x ));
        snake_current_direction=$RIGHT;
    elif [[ ($input == $'\x1b[D' && $snake_current_direction != "$RIGHT") || ($snake_current_direction == "$LEFT" && (${#input} -lt 1 || $input == $'\x1b[C' || ! $input =~ "[A"|"[B" )) ]]
    then
        snake_current_column=$(( snake_current_column - snake_speed_x ));
        snake_current_direction=$LEFT;
    fi;
    
    snake_positions=("$snake_current_row" "$snake_current_column" ${snake_positions[@]});
}

function clear_snake_tail() {
    local snake_positions_length=${#snake_positions[@]};
    local snake_last_column=${snake_positions[$((snake_positions_length - 1))]};
    local snake_last_row=${snake_positions[$((snake_positions_length - 2))]};
    
    # clear tail
    if ! $is_increase_snake_size
    then
        move_to_nd_output "$snake_last_row" "$snake_last_column" " ";
        unset "snake_positions[$((snake_positions_length - 1))]";
        unset "snake_positions[$((snake_positions_length - 2))]";
    else
        is_increase_snake_size=false;
    fi;
}

function handle_snake_render() {
    local snake_positions_length=${#snake_positions[@]};
    local snake_last_column=${snake_positions[$((snake_positions_length - 1))]};
    local snake_last_row=${snake_positions[$((snake_positions_length - 2))]};
    local snake_first_row=${snake_positions[0]};
    local snake_first_column=${snake_positions[1]};
    
    change_text_color $DEFAULT_SPRITE_COLOR;
    change_text_bgcolor $DEFAULT_BG_COLOR;
    
    # update the body after the head
    if (( snake_positions_length > 4 ))
    then
        local snake_second_row=${snake_positions[2]};
        local snake_second_column=${snake_positions[3]};
        move_to_nd_output "$snake_second_row" "$snake_second_column" "$snake_body_design";
    fi;
    
    # draw new head
    move_to_nd_output "$snake_first_row" "$snake_first_column" "$snake_head_design";
}

function is_snake_hit_obstacle() {
    local snake_head_row=${snake_positions[0]};
    local snake_head_column=${snake_positions[1]};
    
    if (( (snake_head_row - snake_speed_y) < MIN_ROW || (snake_head_row + snake_speed_y) > MAX_ROW || (snake_head_column - snake_speed_x) < MIN_COLUMN || (snake_head_column + snake_speed_x) > MAX_COLUMN))
    then
        return 0;
    else
        local snake_positions_length=${#snake_positions[@]};
        
        if (( snake_positions_length > 4 ))
        then
            for (( i=4; i<snake_positions_length; i+=2 ))
            do
                if (( snake_head_row == ${snake_positions[$i]} && snake_head_column == ${snake_positions[$((i+1))]} ))
                then
                    return 0;
                fi;
            done;
        fi;
    fi;
    
    return 1;
}

function is_snake_hit_fruit() {
    if [[ "${snake_positions[0]}" == "${fruit_positions[0]}" && "${snake_positions[1]}" == "${fruit_positions[1]}" ]]
    then
        return 0;
    else
        return 1;
    fi;
}

# game functions
function draw_game_score() {
    move_to 1 0;
    erase_line;
    
    center_text_horizontally_of "SCORE: $score" "$MAX_COLUMN";
}

function handle_game_score_increase() {
    score=$((score + 1));
}

function draw_game_borders() {
    # change_text_bgcolor $DEFAULT_SPRITE_COLOR;
    change_text_color $DEFAULT_SPRITE_COLOR;
    move_to $MIN_ROW $MIN_COLUMN;
    
    # logic is much better than the currently use one
    function old_border_draw () {
        change_text_bgcolor $DEFAULT_SPRITE_COLOR;
        for row in $(seq "$MIN_ROW" "$MAX_ROW")
        do
            if (( row == MIN_ROW || row == MAX_ROW))
            then
                for _ in $(seq "$MAX_COLUMN")
                do
                    # output top wall
                    if (( row == MIN_ROW ))
                    then
                        echo -n " "
                        
                    elif (( row == MAX_ROW ))
                    # output bottom wall
                    then
                        echo -n " "
                    fi;
                done;
            else
                # output left wall
                echo -n " "
                
                # output right wall
                move_to "$row" "$MAX_COLUMN";
                echo -n " "
            fi
        done;
    }
    
    for ((row=MIN_ROW; row<=MAX_ROW; row++))
    do
        for ((column=MIN_COLUMN; column<=MAX_COLUMN; column++))
        do
            # output top wall
            if (( row == MIN_ROW ))
            then
                if (( column == MIN_COLUMN ))
                then
                    move_to_nd_output $row $column "╔";
                elif (( column == MAX_COLUMN ))
                then
                    move_to_nd_output $row $column "╗";
                else
                    move_to_nd_output $row $column "═";
                fi;
                
                # output bottom wall
            elif (( row == MAX_ROW ))
            then
                if (( column == MIN_COLUMN ))
                then
                    move_to_nd_output $row $column "╚";
                elif (( column == MAX_COLUMN ))
                then
                    move_to_nd_output $row $column "╝";
                else
                    move_to_nd_output $row $column "═";
                fi;
                
                # output left wall
            elif (( column == MIN_COLUMN ))
            then
                move_to_nd_output $row $column "|";
                
                # output left wall
            elif (( column == MAX_COLUMN ))
            then
                move_to_nd_output $row $column "|";
            fi;
        done;
    done;
    
    
    # show opacified game_text
    exit_code=$?;
    if [[ $exit_code = 0 ]]
    then
        handle_game_title_render dim use-board-size;
    fi;
    
    change_text_bgcolor $DEFAULT_BG_COLOR;
}

function handle_game_title_render () {
    local height;
    local width;
    
    
    function draw_title() {
        local COLOR=$1;
        local TEXT_1=" ____  _   _    _    _  _______    ____    _    __  __ _____ "
        local TEXT_2="/ ___|| \ | |  / \  | |/ / ____|  / ___|  / \  |  \/  | ____|"
        local TEXT_3="\___ \|  \| | / _ \ | ' /|  _|   | |  _  / _ \ | |\/| |  _|  "
        local TEXT_4=" ___) | |\  |/ ___ \| . \| |___  | |_| |/ ___ \| |  | | |___ "
        local TEXT_5="|____/|_| \_/_/   \_\_|\_\_____|  \____/_/   \_\_|  |_|_____|"
        
        if (( ${#TEXT_1} < "$MAX_COLUMN" ))
        then
            change_text_color "$COLOR";
            
            center_text_horizontally_vertically_of "" $height "$width";
            go_prev_row && go_prev_row;
            center_text_horizontally_of "$TEXT_1" "$width";
            center_text_horizontally_of "$TEXT_2" "$width";
            center_text_horizontally_of "$TEXT_3" "$width";
            center_text_horizontally_of "$TEXT_4" "$width";
            center_text_horizontally_of "$TEXT_5" "$width";
            
            change_text_color "$DEFAULT_SPRITE_COLOR";
        fi;
    }
    
    for arg in "$@"
    do
        if [[ $arg = "use-window-size" ]]
        then
            height=$(( $(get_screen_height) - 1));
            width=$(get_screen_width);
            break;
        elif [[ $arg = "use-board-size" ]]
        then
            height=$MAX_ROW;
            width=$MAX_COLUMN;
            break;
        fi;
    done
    
    for arg in "$@"
    do
        if [[ $arg = "animate" ]]
        then
            # intro animation
            for count in $(seq "$(get_random_btw 1 8)")
            do
                draw_title "$count";
                sleep 2 ;
            done;
            
            draw_title $DEFAULT_SPRITE_COLOR;
        elif [[ $arg = "no-animation" ]]
        then
            draw_title $DEFAULT_SPRITE_COLOR;
        elif [[ $arg = "dim" ]]
        then
            dim_text;
            draw_title $DEFAULT_SPRITE_COLOR;
            undo_dim_text;
        fi;
    done;
}

function setup_game() {
    function reset_game_score() {
        score=0;
    }
    
    function reset_snake_data() {
        local is_initial_snake_head_not_even=false;
        snake_current_direction=$RIGHT;
        snake_positions=();
        is_increase_snake_size=false;
        
        for (( i=0; i<2; i++))
        do
            local row=$(( MAX_ROW / 2 ));
            local column=$(( (MAX_COLUMN / 2) + (snake_speed_x * i) ));
            
            if (( i == 0 ))
            then
                if (( column % 2 != 0 ))
                then
                    is_initial_snake_head_not_even=true;
                fi;
            fi;
            
            if $is_initial_snake_head_not_even;
            then
                column=$((column-1));
            fi;
            
            snake_positions=("$row" "$column" ${snake_positions[@]})
        done;
    }
    
    function reset_fruit_data() {
        fruit_positions=();
        is_fruit_on_screen=false;
    }
    
    clear;
    reset_game_score;
    reset_snake_data;
    reset_fruit_data;
    draw_game_borders;
    draw_game_score;
}

function begin_game() {
    local is_game_paused=false;
    local is_game_over=false;
    
    if $is_first_time
    then
        is_first_time=false;
        # game intro
        clear;
        handle_game_title_render animate use-window-size;
    fi;
    
    
    # refresh_game
    setup_game;
    
    while true
    do
        read -rsn 1 -t 0.05 pause_key
        if [[ $pause_key =~ "P"|"p" ]]
        then
            if $is_game_paused
            then
                is_game_paused=false;
            else
                is_game_paused=true;
            fi;
        fi;
        
        read -rsn 1 -t 0.05 restart_key
        if [[ $restart_key =~ "R"|"r" ]]
        then
            begin_game;
            break;
        fi;
        
        read -rsn 1 -t 0.05 quit_key
        if [[ $quit_key =~ "Q"|"q" ]]
        then
            break;
        fi;
        
        if ! $is_game_paused && ! $is_game_over
        then
            if is_snake_hit_fruit
            then
                is_fruit_on_screen=false;
                is_increase_snake_size=true;
                
                handle_game_score_increase;
                draw_game_score;
            fi;
            
            # check if snake collide wall
            if is_snake_hit_obstacle
            then
                is_game_over=true;
                move_to 0 0;
                erase_line;
                center_text_horizontally_of "GAME OVER !! Your Score is $score" $MAX_COLUMN;
                
                move_to 1 0;
                erase_line;
                center_text_horizontally_of "Press 'r' to restart" $MAX_COLUMN;
            else
                handle_snake_movement;
                handle_snake_render;
                clear_snake_tail;
                
                if ! $is_fruit_on_screen
                then
                    handle_fruit_generate;
                    handle_fruit_render;
                fi;
            fi;
        fi;
    done
}

begin_game
