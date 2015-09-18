#!/bin/bash

# The directory we are pulling the objects from
Obj__directory="$Ash__active_module_directory/objects"

################################################################
# Allocates an object pointer.  Must call `Obj__init` on this
# pointer after this is called.
#
# @param $1: The name of the class to instantiate
# @returns: A pointer to the object
################################################################
Obj__alloc(){
    echo "$1_$(Obj_generate_uuid)"
}

################################################################
# Initializes the object, and calls the objects constructor
#
# @param $1: The object pointer
# @param ${@:2} Any additional parameters to be passed to
#   the objects constructor
################################################################
Obj__init(){
    # Getting the class + uuid
    local position=1
    IFS='_' read -ra segment <<< "$1"
    for part in "${segment[@]}"; do
        if [[ "$position" -eq 1 ]]; then
            local class="$part"
        elif [[ "$position" -eq 2 ]]; then
            local uuid="$part"
        fi
        position=$((position+1))
    done

    # Creating unique variable / method names
    local to_find="$class"_
    local to_replace="$class"_"$uuid"_
    eval "$(cat "$Obj__directory/$class.sh" | sed -e "s:$to_find:$to_replace:g")"

    # Calling the constructor
    Obj__call $1 construct "${@:2}"
}

################################################################
# Gets a value from an object
#
# @param $1: The object pointer
# @param $2: The variable name
# @returns: The value of the variable
################################################################
Obj__get(){
    variable="$1__$2"
    echo ${!variable}
}

################################################################
# Sets a value on an object
#
# @param $1: The object pointer
# @param $2: The variable name
# @param $3: The new value of the variable
################################################################
Obj__set(){
    variable="$1__$2"
    eval $variable="$3"
}

################################################################
# Calls a public method on an object
#
# @param $1: The object pointer
# @param $2: The method name
# @param ${@:3} Any additional parameters to the method
################################################################
Obj__call(){
    "$1__$2" "${@:3}"
}

################################################################
# Prints out all public member variables of an object
#
# @param $1: The object pointer
################################################################
Obj__dump(){
    echo "====== $1 ======"
    (set -o posix ; set) | grep ^$1__ | sed -e "s:$1__::g" | sed -e "s:^:| :g"
    echo "====================================="
}

##################################
# Generates a universally unique
# identifier (UUID) for an object
#
# @returns: A UUID
##################################
Obj_generate_uuid(){
    local UUID_LENGTH=16
    local count=1
    local uuid=""

    while [ "$count" -le $UUID_LENGTH ]
    do
        random_number=$RANDOM
        let "random_number %= 16"
        hexval=$(Obj_map_hex "$random_number")
        uuid="$uuid$hexval"
        let "count += 1"
    done
    echo $uuid
}

##################################
# Converts an integer to a single
# hex value
#
# @param $1: An integer from 1 to 15
# @returns: A hex value
##################################
Obj_map_hex(){
case "$1" in
0)  echo "0"
    ;;
1)  echo "1"
    ;;
2)  echo "2"
    ;;
3)  echo "3"
    ;;
4)  echo "4"
    ;;
5)  echo "5"
    ;;
6)  echo "6"
    ;;
7)  echo "7"
    ;;
8)  echo "8"
    ;;
9)  echo "9"
    ;;
10)  echo "A"
    ;;
11)  echo "B"
    ;;
12)  echo "C"
    ;;
13)  echo "D"
    ;;
14)  echo "E"
    ;;
15)  echo "F"
    ;;
*) echo ""
   ;;
esac
}