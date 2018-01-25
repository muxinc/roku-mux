#!/bin/sh
# 
#   Copyright (C) 2013, 2014 Linaro, Inc
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 

#
# This script converts a DejaGnu .sum file into a Junit copatible
# XML file.
#

if test x"$1" = x; then
  outfile="/tmp/testrun.xml"
  infile="/tmp/testrun.sum"
else
  outfile=`echo $1 | sed -e 's/\.sum.*/.junit/'`
  infile=$1
fi

# Where to put the output file
if test x"$2" != x; then
  outfile=$2
else
  outfile="/tmp/${outfile}"
fi

if test ! -e ${infile}; then
  echo "ERROR: no input file specified!"
  exit
fi

# If compressed, uncompress it
type="`file ${infile}`"
count=`echo ${type} | grep -c "XZ compressed data"`
if test ${count} -gt 0; then
  catprog="xzcat"
  decomp="xz -d"
  comp="xz"
else
  count=`echo ${type} | grep -c "XZ compressed data"`
  if test ${count} -gt 0; then
    catprog="gzcat"
    decomp="gzip"
    comp="gunzip"
  else
    catprog="cat"
  fi
fi

#
#${decomp} ${infile}
#infile="`echo ${infile} | sed -e 's:\.xz::' -e 's:\.gz::'`"
tool="Tests"

# Get the counts for tests that didn't work properly
skipped="`egrep -c '^UNRESOLVED|^UNTESTED|^UNSUPPORTED|^SKIP:' ${infile}`"
# skipped="`egrep -c '^SKIP:' ${infile}`"
if test x"${skipped}" = x; then
    skipped=0
fi

# The total of successful results are PASS and XFAIL
passes="`egrep -c '^PASS:|XFAIL' ${infile}`"
if test x"${passes}" = x; then
    passes=0
fi

# The total of failed results are FAIL and XPASS
failures="`egrep -c '^FAIL:|ERROR:|XPASS' ${infile}`"
if test x"${failures}" = x; then
    failures=0
fi

# Calculate the total number of test cases
total="`expr ${passes} + ${failures}`"
total="`expr ${total} + ${skipped}`"

cat <<EOF > ${outfile}
<?xml version="1.0"?>

<testsuites>
<testsuite name="brstest" tests="${total}" failures="${failures}" skipped="${skipped}">

EOF

#Prints out a <testcase> for each passed test which Jenkins will count
for ((i=0; i < (${total} - ${failures}); i++))
  do
    echo "  <testcase name=\"Passed Test ${i}\" classname=\"${tool}\" />" >> ${outfile}
done

# Reduce the size of the file to be parsed to improve performance. Junit
# ignores sucessful test results, so we only grab the failures and test
# case problem results.
tmpfile="${infile}.tmp"
rm -f ${tmpfile}
egrep 'XPASS|FAIL:|ERROR:|UNTESTED|UNSUPPORTED|UNRESOLVED|SKIP:' ${infile} > ${tmpfile}

while read line
do
    # echo -n "."
    result="`echo ${line} | cut -d ' ' -f 1 | tr -d ':'`"
    name="`echo ${line} | cut -d ' ' -f 2`"
    tool="`echo ${line} | cut -d ' ' -f 3`"
    tool=${tool##*/}
    message="`echo ${line} | cut -d ' ' -f 4-50 | tr -d '\"><;:\[\]^\\&?@'`"

    echo "    <testcase name=\"${name}\" classname=\"${tool}-${result}\">" >> ${outfile}
    case "${result}" in
  UNSUPPORTED|UNTESTED|UNRESOLVED|SKIP)
      if test x"${message}" != x; then
    echo "        <skipped message=\"${message}\" />" >> ${outfile}
      else
    echo "        <skipped type=\"${result}\" />" >> ${outfile}
      fi
      ;;
  XPASS|XFAIL)
      echo "        <failure message=\"${message}\" />" >> ${outfile}
      ;;
  *)
      echo "        <failure message=\"${message}\" />"  >> ${outfile}
    esac
    echo "    </testcase>" >> ${outfile}
done < ${tmpfile}
rm -f ${tmpfile}

# Write the closing tag for the test results
echo "</testsuite>" >> ${outfile}
echo "</testsuites>" >> ${outfile}

# compress the file again
#${comp} ${infile}

