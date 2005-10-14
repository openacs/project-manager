# 

ad_page_contract {
    
    Shows all the emails for a project
    
    @author Alex Kroman (alexk@bread.com)
    @creation-date 2004-04-30
    @arch-tag: 339a6143-11a3-4f1b-902d-a3cd71f7d531
    @cvs-id $Id$

} {
    project_item_id:integer
} -properties {
} -validate {
} -errors {
}

permission::require_permission -object_id $project_item_id -privilege "read"

set title "[_ project-manager.Project_Emails]"

set context [list "one?project_item_id=$project_item_id" "[_ project-manager.Project_1]" "[_ project-manager.Project_Emails]"]

set mt_installed_p [apm_package_installed_p "mail-tracking"]
