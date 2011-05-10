#!/bin/bash

# Script for getting some stats from git repositories
#
# Copyright (C) 2011, Emergya
# Author(s): Juanje Ojeda <jojeda@emergya.es>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See http://www.gnu.org/copyleft/gpl.html for
# the full text of the license.

root_dir=$PWD
years=(2009 2010 2011)
export IFS=$'\x0A'$'\x0D'

if [ -d "$1" ]; then
    root_dir="$1"
fi

get_projects()
{
    for dir in $(find $root_dir -maxdepth 1 -type d ); do
        if [ -d $dir/.git ]; then
            echo ${dir##*/}
        fi
    done
}

projects=( $(get_projects) )
for project in ${projects[@]}; do
    cd ${root_dir}/${project}
    authors=( $(git log --pretty=format:%aN | sort -u) )
    for year in ${years[@]}; do
        for author in ${authors[@]}; do
            commits=$(git log --oneline --author="${author}" \
                      --since="${year}-01-01" --until="${year}-12-31" | wc -l)
            echo "${year};${project};${author};${commits}"
        done
    done
done
    
