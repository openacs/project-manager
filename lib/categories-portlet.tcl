# packages/project-manager/lib/comments-portlet.tcl
#
# Comments Portlet
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: 4bf09cbf-1cdd-4346-9346-a4347faf76ba
# @cvs-id $Id$

# categories

set categories [list]
set cat_list [category::get_mapped_categories $item_id]
foreach cat $cat_list {
    lappend categories [category::get_name $cat]
}
set cat_length [llength $categories]
