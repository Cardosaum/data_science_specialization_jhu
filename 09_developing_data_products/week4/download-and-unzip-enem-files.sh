#!/bin/bash
basePath=$(pwd)

# donwload files
enem2019url="http://download.inep.gov.br/microdados/microdados_enem_2019.zip"
enem2018url="http://download.inep.gov.br/microdados/microdados_enem2018.zip"
enem2017url="http://download.inep.gov.br/microdados/microdados_enem2017.zip"
enem2016url="http://download.inep.gov.br/microdados/microdados_enem2016.zip"
enem2015url="http://download.inep.gov.br/microdados/microdados_enem2015.zip"
enem2014url="http://download.inep.gov.br/microdados/microdados_enem2014.zip"
# enem2013url="http://download.inep.gov.br/microdados/microdados_enem2013.zip"

echo
echo "******************************"
echo "Starting Download"
echo "******************************"
echo

cd ./data
for i in {2014..2019}; do
    name="${i}.zip"
    url="enem${i}url"
    echo wget --no-clobber --quiet --output-document="${name}" "${!url}" &
    wget --no-clobber --quiet --output-document="${name}" "${!url}" &
done
cd ".."

# wait until downloads end
wgetWait=$(pgrep -a -f "^wget.*no-clobber.*enem.*")
until [[ -z "$wgetWait" ]]; do
    clear
    echo "=============================="
    echo "Waiting Download Finish..."
    echo "Current Donwloads:"
    echo "${wgetWait}"
    echo "=============================="
    echo
    sleep 5
    wgetWait=$(pgrep -a -f "^wget.*no-clobber.*enem.*")
done
echo
echo "******************************"
echo "Download Ended!"
echo "******************************"
echo

echo
echo "******************************"
echo "Starting Unzip"
echo "******************************"
echo
# unzip files
zips=$(fd -a -e zip . "data/")
echo "${zips}" | while read -r i
do
    year=$(basename -s .zip "${i}")
    enemParent=$(dirname "${i}")
    enemDir="${enemParent}/enem${year}"
    mkdir -vp "${enemDir}"
    cd "${enemDir}"
    enemChildDirs=$(fd -d 1 -t d)
    if [[ -z "${enemChildDirs}" ]]; then
        echo 7z x "${i}" -o"${enemDir}"
        7z x "${i}" -o"${enemDir}" &
    fi
    cd "${basePath}"
done
unzipWait=$(pgrep -a -f "7z\s+x\s+.*enem.*")
until [[ -z "${unzipWait}" ]]; do
    clear
    echo "=============================="
    echo "Waiting Unzip Finish..."
    echo "Current Unzips:"
    echo "${unzipWait}"
    echo "=============================="
    echo
    sleep 5
    unzipWait=$(pgrep -a -f "7z\s+x\s+.*enem.*")
done
echo
echo "******************************"
echo "Unzip Ended!"
echo "******************************"
echo
