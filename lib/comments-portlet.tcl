# packages/project-manager/lib/comments-portlet.tcl
#
# Comments Portlet
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: 4bf09cbf-1cdd-4346-9346-a4347faf76ba
# @cvs-id $Id$

# ----------------
# general comments
# ----------------
set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 $project_item_id "[ad_conn url]?project_item_id=$project_item_id"]

set comments_link "<a href=\"[export_vars -base "comments/add" {{ object_id $project_item_id} {title "[pm::util::get_project_name -project_item_id $project_item_id -project_id $project_id]"} {return_url [ad_return_url]} {type project} }]\">[_ project-manager.Add_comment]</a>"

