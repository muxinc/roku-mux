#!/bin/bash

ip=$1
unit_test_folder=$2
test_results_file=$3


echo "*** Starting Testing ***"

# Run tests
$2/runtests.sh $ip | tee out.tmp
wait

# convert to xUnit
$2/sum2junit.sh out.tmp $3
wait

# delete out.tmp
rm -f out.tmp

# Finished!
echo "*** Finished Testing ***"