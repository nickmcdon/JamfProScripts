#!/bin/sh

dseditgroup -o edit -a "everyone" -t group lpadmin

exit $?