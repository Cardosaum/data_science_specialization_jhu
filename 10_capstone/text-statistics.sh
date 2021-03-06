#!/bin/bash

# find files to work with
sourceFiles=$(fd --no-ignore -a -e txt "^en_US")

# loop through files and generate statiscs for them
echo "${sourceFiles}" | while read -r file; do
    fileDir=$(dirname "${file}" | xargs readlink -f)
    fileBase=$(basename --suffix=.txt "${file}")
    outBase="count_${fileBase}"
    echo "Processing file: $(basename ${file})"
    [[ ! -f "${fileDir}/character_${outBase}.csv" ]] && rg --text "\w" -INo "${file}" | tr "[:upper:]" "[:lower:]" | sort | uniq -c | perl -pe 's/^\s+//g' | perl -pe 's/\s+/,/' | sort -rg | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/character_${outBase}.csv"
    [[ ! -f "${fileDir}/wordOnly_${outBase}.csv" ]] && rg --text "(\w+'\w+)|\w+" -INo "${file}" | tr "[:upper:]" "[:lower:]" | sort | uniq -c | perl -pe 's/^\s+//g' | perl -pe 's/\s+/,/' | sort -rg | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/wordOnly_${outBase}.csv"
    # [[ ! -f "${fileDir}/digitOnly_${outBase}.csv" ]] && rg --text "\d+" -INo "${file}" | sort | uniq -c | perl -pe 's/^\s+//g' | perl -pe 's/\s+/,/' | sed '1s/^/count,character\n/' > "${fileDir}/digitOnly_${outBase}.csv" &
    # [[ ! -f "${fileDir}/wordAndDigit_${outBase}.csv" ]] && rg --text "[\w'\d]+" -INo "${file}" | sort | uniq -c | perl -pe 's/^\s+//g' | perl -pe 's/\s+/,/' | sed '1s/^/count,character\n/' > "${fileDir}/wordAndDigit_${outBase}.csv" &
    # [[ ! -f "${fileDir}/wordAndDigitWithPontuation_${outBase}.csv" ]] && rg --text "\S+" -INo "${file}" | sort | uniq -c | perl -pe 's/^\s+//g' | perl -pe 's/\s+/,/' | sed '1s/^/count,character\n/' > "${fileDir}/wordAndDigitWithPontuation_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_1grams_${outBase}.csv" ]] && ./ngrams -n1 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_1grams_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_2grams_${outBase}.csv" ]] && ./ngrams -n2 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_2grams_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_3grams_${outBase}.csv" ]] && ./ngrams -n3 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_3grams_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_4grams_${outBase}.csv" ]] && ./ngrams -n4 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_4grams_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_5grams_${outBase}.csv" ]] && ./ngrams -n5 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_5grams_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_6grams_${outBase}.csv" ]] && ./ngrams -n6 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_6grams_${outBase}.csv"
    [[ ! -f "${fileDir}/ngrams_7grams_${outBase}.csv" ]] && ./ngrams -n7 -sn "${file}" | rg "\s+(\d+)\s+(([\w']+\s?)+)" -r '$1,$2' | rg -vwF -f data/bad_words_list.txt | sed '1s/^/count,character\n/' > "${fileDir}/ngrams_7grams_${outBase}.csv"

    # filter stopwords from ngrams
    ngramFiles=$(fd --no-ignore -a "ngrams_.*en.*" -e csv | rg -v "without_stopwords" | rg -v "filtered" | rg "${fileBase}")
    echo "${ngramFiles}" | while read -r ngram; do
        xgram=$(echo "${ngram}" | rg -o "\dgrams")
        nonstopwordngramfile="${fileDir}/ngrams_${xgram}_without_stopwords_${outBase}.csv"
        [[ ! -f "${nonstopwordngramfile}" ]] && rg -vwF -f data/stopwords.txt "${ngram}" > "${nonstopwordngramfile}"

        # filter ngrams bigger values
        mlrbiggerthanfive=$"${fileDir}/ngrams_filtered_${xgram}_${outBase}.csv"
        [[ ! -f "${mlrbiggerthanfive}" ]] && mlr --csv filter '$count >= 5' "${ngram}" > "${mlrbiggerthanfive}"

    done


done

if [[ "${@}" =~ "--overwrite" ]]; then
    echo
    echo "Overwriting existing data..."
    echo
    echo "Generating line count statistics..."
    rm -vf "data/line_count_parsed.csv" ; fd --no-ignore -e txt -e csv "en_US" | sort | xargs wc -cmlLw | perl -pe 's/^\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\w+)/\1,\2,\3,\4,\5,\6/g' | rg -C1000 "(.*),.*/(.*\.csv$)" -r '$1,$2' | sed '1s/^/num_of_lines,num_of_words,num_of_characters,num_of_bytes,maximum_line_length,file_name\n/' > "data/line_count_parsed.csv"

    echo
    echo "Generating file size statistics..."
    rm -vf "data/file_size_parsed.csv" ; fd --no-ignore -e txt -e csv "en_US" -l | sort | perl -pe 's/^.*earth\s+//g' | sort -h | perl -pe 's/(^\d+(\.\d+)?\w).*(data.*$)/\1,\3/' | rg "(^\d+\.?\d+?\w?),.*/en_US/(.*)" -r '$1,$2' | sed '1s/^/size,file\n/' > "data/file_size_parsed.csv"
    echo
fi

echo "Processing is Over!"

