#!/bin/bash
for number in {1..100};
do 
    if [[ $number -le 20 && $number -ge 40 && $number -le 60 ]]; then
        echo $number
    fi

    
done