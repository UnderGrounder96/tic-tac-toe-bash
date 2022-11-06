#!/usr/bin/env bash

: "
Author: UnderGrounder96
Creation on: 20-Nov-2022
"

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${ROOT_DIR}/extras

# enable strict mode
# set -euo pipefail

# declare array (to print on the screen)
declare -a table


function welcome() {

    _logger_info "Hello there, gamer ${USER}!"

    _sleep

    _logger_info "Feel free to (S)ave or (Q)uit at anytime"
}

function show_table() {

    _logger_info "Showing the current table status"

    _sleep

    echo "
    [${table[0]}] [${table[1]}] [${table[2]}]
    [${table[3]}] [${table[4]}] [${table[5]}]
    [${table[6]}] [${table[7]}] [${table[8]}]
"
}

function run_program() {

    save_file="${1}"

    index=
    value=

    block_save=1

    retries=2


    while true; do
        # show current table status

        _sleep
        show_table

        # receive the table index
        while true; do
            _logger_info "Which index would you like to update"

            read -rn 1 ans

            _sleep
            case "${ans}" in
                [0-8])
                    index="${ans}"
                    break
                    ;;

                [Hh])
                    _game_instruction
                    ;;

                [Ss] | [Cc])
                    if [[ "${block_save}" -eq 1 ]]; then
                        _logger_info "Table has not changed in size. Skipping..."

                        _check_wrong_option $retries

                        retries=$((retries - 1))

                        continue

                    elif [[ "${block_save}" -eq 2 ]]; then
                        _logger_info "Game was already saved"

                        _check_wrong_option $retries

                        retries=$((retries - 1))

                        continue
                    fi

                    _sleep

                    _save_game ${save_file}

                    block_save=2
                    ;;

                [Qq])
                    if [[ "${block_save}" -eq 0 ]]; then
                        _save_game ${save_file}
                    fi

                    _logger_info "Quiting. Good bye"

                    # notice how we leave the func with return instead of exit
                    return 0
                    ;;

                *)
                    _check_wrong_option $retries

                    retries=$((retries - 1))
                    ;;
            esac
        done

        _sleep

        # receive the table value
        while true; do
            _logger_info "Which value would you like to update"

            # read one char
            read -rn 1 ans

            _sleep

            _logger_info "Gamer has provided the option: ${ans}"

            case "${ans}" in
                [Xx] | [Oo])
                    value="${ans}"

                    if [[ "${block_save}" -eq 1 ]]; then
                        # lift save blocker
                        block_save=0
                    fi

                    break
                    ;;

                [Hh])
                    _game_instruction
                    ;;

                [Ss] | [Cc])
                    if [[ "${block_save}" -eq 1 ]]; then
                        _logger_info "Table has not changed in size. Skipping"

                        _sleep

                        _check_wrong_option $retries

                        retries=$((retries - 1))

                        continue

                    elif [[ "${block_save}" -eq 2 ]]; then
                        _logger_info "Game was already saved"

                        _check_wrong_option $retries

                        retries=$((retries - 1))

                        continue
                    fi

                    _save_game ${save_file}

                    block_save=0
                    ;;

                [Qq])
                    if [[ "${block_save}" -eq 0 ]]; then
                        _save_game ${save_file}
                    fi

                    _logger_info "Quiting. Good bye"

                    # notice how we leave the func with return instead of exit
                    return 0
                    ;;

                *)
                    _check_wrong_option $retries

                    retries=$((retries - 1))
                    ;;
            esac
        done


        _update_move "${index}" "${value}"
    done
}

function start_game() {

    save_file=".saved_game"

    _sleep

    # load the save data, if present
    if [[ -f "${save_file}" ]]; then
        # TODO: Check file loading using regex
        # TODO: Allow the player to load any savefile, not only latest

        # regex="[[:digit:]]"

        _logger_info "Loading file data"

        for i in `cat .saved_game`; do
            j=`echo ${i} | cut -d '=' -f 1`
            table[${j}]=`echo ${i} | cut -d '=' -f 2`
        done
    fi

    run_program ${save_file}
}


function main() {

    # print welcome message
    welcome

    # start the game
    start_game


    exit 0
}

_sleep

# handle script arguments
if [[ "$#" -ne 0 ]]; then
  case "${1}" in
    -h | --help)
      _logger_info "Printing game instructions"
      _help
      exit 0
      ;;

    *)
      _logger_info "This program only allows the flag -h/--help"
      _logger_info "Unrecognised argument provided. Exiting"
      exit 1
      ;;
  esac
fi

main
