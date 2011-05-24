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

## Get the data from a cvs file which should looks like:
# Lists,Año 2009,Año 2010,Año 2011
# org.drupal.development,1,0,1
# org.gnome.orca-list,78,0,12
contents <- read.csv('dataset.csv', header = T)

# Graphs
barplot(as.matrix(contents[c(2,3,4)]),
    col=rainbow(20),
    xlab='Año',
    ylab='Número de correos',
    ylim= c(0,100),
    main="Correos por año",
#    legend.text=contents$Lists,
    beside=T)

# Queries
## GNOME lists and its number of mails
cat("Lists about GNOME:\n")
subset(contents, grepl("*gnome*", contents$Lists))

## Print the list with more mails per each year
cat("\nLists with more mails per each year:\n")
cat("Año\t\tLista\n")
for (year in seq(2, 4)) {
    max_mails <- which.max(contents[[year]])
    titles <- colnames(contents)
    cat(sprintf("%s\t%s\n",
                titles[year],
                contents$Lists[max_mails]))
}

# Print the total mails per year
cat("\nTotal mails per year:\n")
colSums(contents[,c(2,3,4)])
