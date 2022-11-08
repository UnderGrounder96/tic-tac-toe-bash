#!/usr/bin/env bash

: "
Author: UnderGrounder96
Creation on: 20-Nov-2022
"

value=
GAMER="${USER}"
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${ROOT_DIR}/extras

# enable strict mode
# set -euo pipefail

# declare array (to print on the screen)
declare -a table


if [[ $((${RANDOM} % 2 )) -eq 0 ]]; then
    value="O"
else
    value="X"
fi


function welcome() {

    _logger_info "Hello there, gamer ${GAMER}!"

    _sleep

    _logger_info "Feel free to (S)ave or (Q)uit at anytime"
}

function good_bye() {
    if [[ "${block_save}" -eq 0 ]]; then
        _save_game "${save_file}"
    fi

    _logger_info "Quiting. Good bye"
}

function run_program() {
    # TODO: Improve save workflow

    save_file="${1}"

    if [[ ! -z "${2}" ]]; then
        value="${2}"
    fi

    index=

    block_save=1

    retries=2


    while true; do
        # show current table status

        _sleep
        _show_table

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

                [Rr])
                    retries=$((retries - 1))

                    _reset_table

                    if [[ "$?" -eq 1 ]]; then
                        _check_wrong_option "${retries}"
                    else
                        _logger_info "You have ${retries} reset available"
                    fi
                    ;;

                [Ss] | [Cc])
                    if [[ "${block_save}" -eq 1 ]]; then
                        _logger_info "Game is already saved, maybe"

                        _check_wrong_option "${retries}"

                        retries=$((retries - 1))

                        continue
                    fi

                    _sleep

                    _save_game "${save_file}"

                    block_save=1
                    ;;

                [Qq])
                    good_bye

                    # notice how we leave the func with return instead of exit
                    return 0
                    ;;

                *)
                    _check_wrong_option "${retries}"

                    retries=$((retries - 1))
                    ;;
            esac
        done

        _sleep

        _update_move "${index}" "${value}"

        if [[ "$?" -eq 1 ]]; then
            _check_wrong_option "${retries}"

            retries=$((retries - 1))

            continue
        else
            if [[ "${value}" == "O" ]]; then
                value="X"
            else
                value="O"
            fi
        fi


        if [[ "${block_save}" -eq 1 ]]; then
            # lift save blocker
            block_save=0
        fi

        _logger_info "${GAMER} will use - '${value}'"
    done
}

function start_game() {

    save_file=".saved_game"

    _sleep

    # load the save data, if present
    if [[ -f "${save_file}" ]]; then
        # TODO: Check file loading using regex
        # TODO: Allow player to load any savefile, not only latest

        # regex="[[:digit:]]"

        _logger_info "Loading file data"

        value=`head -1 ${save_file} | cut -d '=' -f 2`

        # delete first line
        # sed -i '1d' ${save_file}

        for i in `tail -n +2 ${save_file}`; do
            i=`echo ${i} | cut -d '=' -f 2`

            if [[ ! -z "${i}" ]]; then
                j=`echo ${i} | cut -d '=' -f 1`

                table[${j}]="${i}"
            fi
        done
    fi

    _logger_info "${GAMER} will use - '${value}'"

    run_program "${save_file}" "${value}"
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
