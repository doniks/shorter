#!/bin/bash 

grep \
    --exclude-dir=build \
    --exclude-dir=po \
    --exclude=CMakeLists.txt.user \
    --color=always \
    -niR \
    $*

