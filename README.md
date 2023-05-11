# Data Handler

This directory stores R scripts to handle date time in csv files.

# Script: datetype_identifier
This script intends to identify which date time pattern is in a '.csv' file. After identifying which date pattern is used, it transform this into a column of class "POSIXct".

Improvements yet to do:
* Support to '.pdf' and '.xls' extensions.
* Add error exceptions.
* Add condition when Date time are separated into two columns.
