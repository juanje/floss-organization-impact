#!/usr/bin/env Rscript

# This script will perfomance some queries and plot some graphs
# from a data stored in a CSV file
#
# This software is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Copyright (c) 2011, Emergya
# Authors: Juanje Ojeda (mailto:jojeda@emergya.es)

contents <- read.csv('git-dataset.csv', header = T)

projects <- levels(contents$Project)

for (project in projects) {
    cat(sprintf("\n\n%s\n", project))
    project_data <- subset(contents, Project==project, select=c(Date, Author))
    authors <- levels(project_data$Author)
    for (author in authors) {
        commits <- nrow(subset(project_data, Author == author))
        cat(sprintf("%s: %s\n", author, commits))
    }
}

