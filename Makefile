SHELL := /bin/bash

PARSER_DIR    = ./parsers
EYAPP_OPTIONS = -Cv

# --------------------------------------------
# Build the parser
# --------------------------------------------

${PARSER_DIR}/procedural.pm: procedural.yp
	eyapp -Cv -o $@ $<
	mv procedural.output ${PARSER_DIR}/

# --------------------------------------------
# Generic rules
# --------------------------------------------

all: ${PARSER_DIR}/procedural.pm

test: all
	perl test.pl

clean:
	rm -f ${PARSER_DIR}/*.pm
	rm -f ${PARSER_DIR}/*.output
