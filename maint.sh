#!/bin/bash

try_failed() {
	# some day, make failure optional, elect to continue with -f?
	echo "[fail] Aborting"
	echo "[fail] Step: $1"
	echo "[fail] Command: $2"
	echo "[fail] Status: $3"
	exit $3
}

try() {
	echo "[command] $1"
	sudo /bin/sh -c "$2"
	R=$?
	if [[ $R -ne 0 ]] ; then
		try_failed "$1" "$2" "$R"
	fi
}

try "Check that we can really run commands" "id -a"
try "Update all packages" "emerge -uDN --with-bdeps=y --complete-graph @world"
try "Rebuild preserved libraries" "emerge @preserved-rebuild"
try "Fix broken reverse-dependencies" "revdep-rebuild"
try "Fix outdated Python modules" "python-updater --enable-all"
try "Fix Perl modules, step 1" "perl-cleaner --modules"
try "Fix Perl modules, step 2" "perl-cleaner --phall"
try "Review patched configuration files" "dispatch-conf"
