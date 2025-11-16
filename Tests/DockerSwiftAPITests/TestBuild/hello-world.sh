#!/bin/sh

echo "Hello World!"

if [[ -f "ignore_this_file.txt" ]]; then
    exit 1
fi

