#!/bin/sh

bail()
{
	if [ "x$tmpdir" != "x" ]; then
		rm -rf $tmpdir
	fi
	exit $1
}

cfg=$(realpath $1)
prog=$(realpath $2)
in=$(realpath $3)
ans=$(realpath $4)
out=$(realpath $5)

source $cfg

# move program into a transient global-accessable directory
tmpdir=$(mktemp -d opojXXXXXXXX -p /tmp)
chmod 711 $tmpdir

if [ "x$mem_limit" = "x" ]; then
	# default
	mem_limit=1G
fi

if [ "x$out_limit" = "x" ]; then
	# default
	out_limit=8M
fi

if [ "x$time_limit" = "x" ]; then
	echo "time limit must be set in problem configuration file"
	bail 1
fi

cmd="sudo systemd-run --wait --collect"

# limit to one core
cmd="$cmd -p CPUQuota=100%"

# memory limit
cmd="$cmd -p MemoryMax=$mem_limit"
cmd="$cmd -p MemorySwapMax=0"

# run time limit
cmd="$cmd -p RuntimeMaxSec=$time_limit"

# do not dump core
cmd="$cmd -p LimitCORE=0"

# output limit
cmd="$cmd -p LimitFSIZE=$out_limit"

# use transient user
cmd="$cmd -p DynamicUser=true"
cmd="$cmd -p BindReadOnlyPaths=$tmpdir"

# set up stdin
cmd="$cmd -p StandardInput=file:$in"

# make a writable file
touch $tmpdir/out.txt
chmod 666 $tmpdir/out.txt

# set up stdout
cmd="$cmd -p StandardOutput=file:$tmpdir/out.txt"

# set up program
install -vm755 $prog $tmpdir/exe
cmd="$cmd $tmpdir/exe"

$cmd 2> $tmpdir/judge_log

# check for JE
if [ "$(cat $tmpdir/judge_log | wc -l)" -lt 2 ]; then
	bail 1
fi

# check for TL
if head -n2 $tmpdir/judge_log | tail -n1 | grep timeout > /dev/null; then
	echo TL > $out
	bail 0
fi

# check for RE
if ! head -n2 $tmpdir/judge_log | tail -n1 | grep success > /dev/null; then
	echo RE > $out
	bail 0
fi

if diff -Z $ans $tmpdir/out.txt; then
	echo AC > $out
	bail 0
fi

echo WA > $out
bail 0
