#! /bin/bash

#
# how lame... a Linux bash shell script
# for a DOS game? this is nuts!
#

set -x
set -e

VERSION=2
OUTPUT=packman${VERSION}
OUTPUT_FILE=${OUTPUT}.zip

git archive master --format=zip  > ${OUTPUT_FILE}
cp PACKMAN.EXE PACKMAN2.EXE
zip -d ${OUTPUT_FILE} .gitignore readme.md makezip.sh
zip -r ${OUTPUT_FILE} PMLE.EXE PACKMAN2.EXE
