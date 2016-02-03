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

try "Verify up-to-date Portage" "emerge -1u portage"
try "Check for gentoolkit" "emerge -1u gentoolkit"
try "Rebuild packages broken by GCC 5 ABI" "revdep-rebuild --library 'libstdc++.so.6' -- --exclude gcc"
if [[ $(find /usr/lib*/python3* -name '*cpython-3[3-5].so | wc -l) -gt 0 ]]
then try "Fix Python 3 ABI bustage" "emerge -1 $(find /usr/lib*/python3* -name '*cpython-3[3-5].so')"
fi
try "Update all packages" "emerge -uDN --with-bdeps=y --complete-graph @world"
try "Rebuild preserved libraries" "emerge @preserved-rebuild"
try "Fix broken reverse-dependencies" "revdep-rebuild"
try "Fix outdated Python modules" "python-updater --enable-all"
try "Fix Perl modules, step 1" "perl-cleaner --modules"
try "Fix Perl modules, step 2" "perl-cleaner --phall"
try "Review patched configuration files" "dispatch-conf"
try "Review new news items" "eselect news read new"
