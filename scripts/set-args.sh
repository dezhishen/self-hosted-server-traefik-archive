#! /bin/bash
arg_name=$1
value=$2
echo $value > `dirname $0`/../.args/$arg_name