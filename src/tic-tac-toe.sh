#!/usr/bin/env bash

: "
Author: UnderGrounder96
Creation on: 20-Nov-2022

The game is hard by design.
Allowing only 3 mistakes from the player.
And if you save, AI may have +1 turn.
"

value=
GAMER=
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${ROOT_DIR}/extras

# enable strict mode
# set -euo pipefail

# declare array (to print on the screen)
declare -a table


if [[ $((${RANDOM} % 2 )) -eq 0 ]]; then
    value="O"
    GAMER="${USER}"
else
    value="X"
    GAMER="AI"
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

        _logger_info "Current turn: ${GAMER}'s with will use - '${value}'"

        _sleep
        _show_table

        if [[ "${GAMER}" == "AI" ]]; then

            _logger_info "${GAMER} is thinking"

            _check_for_ai "${value}"

            index="${?}"
        else
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
        fi

        _sleep

        _update_move "${index}" "${value}"

        if [[ "$?" -eq 1 ]]; then
            _check_wrong_option "${retries}"

            retries=$((retries - 1))

            continue
        else
            if [[ "${value}" == "O" ]]; then
                value="X"
                GAMER="AI"
            else
                value="O"
                GAMER="${USER}"
            fi
        fi


        if [[ "${block_save}" -eq 1 ]]; then
            # lift save blocker
            block_save=0
        fi
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

        if [[ "${value}" == "O" ]]; then
            value="X"
            GAMER="AI"
        else
            value="O"
            GAMER="${USER}"
        fi

        # delete first line
        # sed -i '1d' ${save_file}

        for i in `tail -n +2 ${save_file}`; do
            k=`echo ${i} | cut -d '=' -f 2`

            if [[ ! -z "${k}" ]]; then
                j=`echo ${i} | cut -d '=' -f 1`

                table[${j}]="${k}"
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
