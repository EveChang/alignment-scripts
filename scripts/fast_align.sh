#!/bin/bash

set -e

# check if MGIZA_DIR is set and installed
if [ -z ${FASTALIGN_DIR} ]; then
  echo "Set the variable FASTALIGN_DIR"
  exit
fi

if [ ! -f ${FASTALIGN_DIR}/build/fast_align ]; then
  echo "Install fastalign, file ${FASTALIGN_DIR}/build/fast_align not found"
  exit
fi

# check parameter count and write usage instruction
if (( $# != 2 )); then
  echo "Usage: $0 source_file_path target_file_path"
  exit
fi

source_path=$1
target_path=$2
source_name=${1##*/}
target_name=${2##*/}

# create format used for fastalign
paste -d "~" ${source_path} ${target_path} | sed 's/~/ ||| /g' > ${source_name}_${target_name}
paste -d "~" ${target_path} ${source_path} | sed 's/~/ ||| /g' > ${target_name}_${source_name}

# remove lines which have an empty source or target
sed -e '/^ |||/d' -e '/||| $/d' ${source_name}_${target_name} > ${source_name}_${target_name}.clean
sed -e '/^ |||/d' -e '/||| $/d' ${target_name}_${source_name} > ${target_name}_${source_name}.clean

# align in both directions
${FASTALIGN_DIR}/build/fast_align -i ${source_name}_${target_name}.clean -d -o -v > alignment.talp
${FASTALIGN_DIR}/build/fast_align -i ${target_name}_${source_name}.clean -d -o -v > alignment.reverse.talp

