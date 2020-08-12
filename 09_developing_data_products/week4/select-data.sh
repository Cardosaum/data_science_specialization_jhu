#!/bin/bash
basePath=$(pwd)

echo
echo "******************************"
echo "Starting Selection"
echo "******************************"
echo
# select  files
csvs=$(fd -e csv -a -i "microdados" "./data")
echo "${csvs}" | while read -r i
do
    year=$(echo "${i}" | rg "/enem\d{4}/" -o | rg "\d+" -o)
    enemParent=$(dirname "${i}")
    enemDir="${enemParent}/enem${year}"
    parsedFile="${enemParent}/parsed${year}.csv"
    if [[ ! -f "${parsedFile}" ]]; then
        echo xsv select -d';' 1-20,92-95,100,105-111 "\"${i}\" > \"${parsedFile}\""
        xsv select -d';' 1-20,92-95,100,105-111 "${i}" > "${parsedFile}" &
    fi
done
sleep 2
xsvWait=$(pgrep -a -f "xsv\s+.*enem.*csv")
until [[ -z "${unzipWait}" ]]; do
    clear
    echo "=============================="
    echo "Waiting xsv Finish..."
    echo "Current:"
    echo "${unzipWait}"
    echo "=============================="
    echo
    sleep 5
    xsvWait=$(pgrep -a -f "xsv\s+.*enem.*csv")
done
echo
echo "******************************"
echo "Selection Ended!"
echo "******************************"
echo
