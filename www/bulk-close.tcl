# 

ad_page_contract {
    
    Closes several projects at once.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-02
    @arch-tag: ca6395ca-df76-467c-8b46-65f4370d3248
    @cvs-id $Id$
} {
    project_item_id:integer,multiple
    {return_url "index?assignee_id=[ad_conn user_id]"}
} -properties {
} -validate {
} -errors {
}


permission::require_permission \
    -privilege write \
    -object_id [ad_conn package_id] \

set number 0

foreach project $project_item_id {
    pm::project::close \
        -project_item_id $project

    incr number
}

if {$number > 1} {
    set project_projects projects
} else {
    set project_projects project
} 

ad_returnredirect -message "$number $project_projects closed" $return_url
