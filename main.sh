#!/bin/bash
# from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--build) ./build_app.sh; shift ;;
        -c|--clean) rm -rf build/* ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done