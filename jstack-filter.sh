#!/bin/sh
is_blank() {
    [[ "$1" =~ ^\s*$ ]] && return 0
    return 1
}

IFS=''
should_skip=false
previous_line=""
last_blank=false

jstack $1 | while read line ; do

    if is_blank "$line"; then
        if ! is_blank "$previous_line"; then
            [[ "$should_skip" = false ]] && echo "$previous_line"
            previous_line=""
        fi
        should_skip=false

    elif [[ "$line" =~ (hz\._hzInstance|New\ I/O\ worker|GC\ task) ||
            "$line" =~ (TIMED_WAITING|WAITING|RUNNABLE) ]]; then
        should_skip=true

    elif [[ "$should_skip" = false ]]; then
        if is_blank "$previous_line"; then
            [[ "$last_blank" = false ]] && echo ""
            last_blank=true
        else
            echo "$previous_line"
            last_blank=false
        fi
    fi

    previous_line="$line"
done



