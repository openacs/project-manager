# packages/project-manager/lib/comments-portlet.tcl
#
# Comments Portlet
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: 4bf09cbf-1cdd-4346-9346-a4347faf76ba
# @cvs-id $Id$

# categories

set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]
set cat_trees [list]
set cat_list [category::get_mapped_categories $item_id]
foreach cat $cat_list {
    set tree_id [category::get_tree $cat]
    lappend cat_trees [list [category_tree::get_name $tree_id] [category::get_name $cat] $tree_id]
}

multirow create categories tree_id tree_name category_name
foreach cat [lsort -dictionary -index 0 $cat_trees] {
    util_unlist $cat tree_name cat_name tree_id
    multirow append categories $tree_id $tree_name $cat_name
}
