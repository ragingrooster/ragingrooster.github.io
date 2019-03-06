#!/bin/bash
# Basic Static Analysis Report - BASR.
# Script to automate the first few steps of my typical static analysis process.

LOGFILE=$(pwd)/bsar.log
touch $LOGFILE

if [ -f "$1" ]; then

	echo "--------------------------------------------------------------" >> $LOGFILE
	echo "- Basic Static Analysis Report: $(date) -" >> $LOGFILE
	echo "--------------------------------------------------------------" >> $LOGFILE
	echo "" >> $LOGFILE
	
	file "$1" >> $LOGFILE
	echo "" >> $LOGFILE

	xxd "$1" | head >> $LOGFILE
	echo "" >> $LOGFILE

	openssl dgst -md5 "$1" >> $LOGFILE
	echo "" >> $LOGFILE

	openssl dgst -sha1 "$1" >> $LOGFILE
	echo "" >> $LOGFILE

	openssl dgst -sha256 "$1" >> $LOGFILE
	echo "" >> $LOGFILE

	ssdeep "$1" >> $LOGFILE
	echo "" >> $LOGFILE

	echo "Filesize: $(stat -f%z $1)" >> $LOGFILE

else
	echo "Expected a file." >&2
fi
