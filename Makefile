# GNU Make Manual
# http://gnu.org/software/make/manual/html_node/index.html#SEC_Contents

# Set the name of the source code file
SRC = src/tic-tac-toe.sh

SAVE = .saved_game
LOGS = logs/*

TIMESTAMP = $(shell date +%F_%T)
LOGFILE = logs/tic-tac-toe_$(TIMESTAMP).log

run:
# executes the program normally
		$(SRC)

log:
# executes play section "recording"
		$(SRC) 2>&1 | tee -a $(LOGFILE)

help:
# executes the help function in program
		$(SRC) -h

h: help

debug:
# executes the program in debug mode while "recording"
		bash -x $(SRC) 2>&1 | tee -a $(LOGFILE)

dev: debug

init:
# grants program executable permission, for current user
		chmod u+x $(SRC)

all: init run # clean


clean:
# removes save game file and "recordings"
		rm -f $(SAVE) $(LOGS)
