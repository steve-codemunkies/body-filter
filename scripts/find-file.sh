#!/bin/bash

bucket="testBucket"
prefix=""
objectCount=10
stopAtFirst=1
pattern="test"
breakFirst=1
jsonPath=".Message"
iterations=5

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bucket)
            bucket=$2
            shift 2
            ;;
        -p|--prefix)
            prefix=$2
            shift 2
            ;;
        -o|--objectCount)
            objectCount=$2
            shift 2
            ;;
        -n|--pattern)
            pattern=$2
            shift 2
            ;;
        -m|--manyMatches)
            breakFirst=0
            shift
            ;;
        -j|--jsonPath)
            jsonPath=$2
            shift 2
            ;;
        -i|--iterations)
            iterations=$2
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

found=0
count=1

aws s3api list-objects --bucket "$bucket" --prefix "$prefix" --max-items $objectCount > files.json

while [[ -f files.json ]]
do
    while read key
    do
        aws s3api get-object --bucket "$bucket" --key "$key" temp.json > /dev/null

        if grep -q -i "$pattern"; then
            echo "Match: $key - Message: $(cat temp.json | jq "$jsonPath")"
            found=1
        fi < <(cat temp.json | jq "$jsonPath")

        if [ $found -gt 0 ] && [ $breakFirst -gt 0 ]; then
            break
        fi
    done < <(cat files.json | jq -r '.Contents | .[] | .Key')

    if [[ $found -gt 0 ]] && [[ $breakFirst -gt 0 ]]; then
        break
    else
        echo "Iteration $count completed"
        count=$(expr $count + 1)
    fi

    if [[ $found -gt 0 ]] && [[ $count -gt $iterations ]]; then
        break
    fi

    if [[ -f files.json ]]; then
        nextToken=$( cat files.json | jq -r '.NextToken' )

        aws s3api list-objects --bucket "$bucket" --prefix "$prefix" --max-items $objectCount --starting-token $nextToken > files.json
    fi
done

if [[ -f temp.json ]]; then
    rm temp.json
fi

if [[ -f files.json ]]; then
    rm files.json
fi
