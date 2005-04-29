# 
#
# Displays a table of active process instances
#
# @author Jade Rubick (jader@bread.com)
# @creation-date 2004-10-21
# @arch-tag: 21a71f70-73cb-4152-9f1b-a32932ef2f9b
# @cvs-id $Id$

foreach required_param {} {
    if {![info exists $required_param]} {
        return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
        set $optional_param {}
    }
}

# get open processes

db_multirow -extend {url} instances instances { } {
    set url [pm::process::url \
                 -process_instance_id $instance_id \
                 -project_item_id $my_project_id \
                 -fully_qualified_p "f"]

}
