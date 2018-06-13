#!/bin/bash
#
# Linux Shell Scripting Tutorial 1.05r3, Summer-2002
#
# Written by Vivek G. Gite <vivek@nixcraft.com>
#
# Latest version can be found at http://www.nixcraft.com/
#
# Q4
#

if test $# = 3
then
	case $2 in
	 +) let z=$1+$3;;
	 -) let z=$1-$3;;
	 /) let z=$1/$3;;
	 x|X) let z=$1*$3;;
	 *) echo Warning - $2 invalied operator, only +,-,x,/ operator allowed
	    exit;;
	esac
	echo Answer is $z
else
	echo "Usage - $0   value1  operator value2"
	echo "        Where, value1 and value2 are numeric values"
	echo "               operator can be +,-,/,x (For Multiplication)"
fi


#
# ./ch.sh: vivek-tech.com to nixcraft.com referance converted using this tool
# See the tool at http://www.nixcraft.com/uniqlinuxfeatures/tools/
#
