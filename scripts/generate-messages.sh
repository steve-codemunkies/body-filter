#!/bin/bash

iterations=100
topic='testtopic'

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--iterations)
            iterations=$2
            shift 2
            ;;
        -t|--topic)
            topic=$2
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

snsMessages=(
    "Welcome to our test script!"
    "Please enter your username."
    "Please enter your password."
    "Click the login button."
    "You have successfully logged in!"
    "Please select an item from the menu."
    "Please enter the quantity of the item you want to purchase."
    "Click the add to cart button."
    "You have successfully added the item to your cart!"
    "Thank you for using our test script!"
)

arraySize=${#snsMessages[@]}

for i in $(seq 0 $iterations); do
    index=$(($RANDOM % arraySize))
    value=${snsMessages[index]}
    
    aws sns publish --topic-arn $topic --message "$value" > /dev/null

    if [ $iterations -lt 1001 ] && [ $(($i % $(($iterations / 10)))) == 0 ]; then
        echo "Written $i"
    elif [ $(($i % $(($iterations / 100)))) == 0 ]; then
        echo "Written $i"
    fi
done