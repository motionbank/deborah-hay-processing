#!/bin/bash

MEM_MIN=1024m
MEM_MAX=1024m
ENCODING=UTF-8

if [ -e build/wordsplit.jar ]; then
  java -Xmx$MEM_MAX -Xms$MEM_MIN -Dfile.encoding=$ENCODING \
    -jar build/wordsplit.jar $1 $2
else
  echo "To compile Word Split type: ant"
fi

