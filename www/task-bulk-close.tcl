# 

ad_page_contract {
    
    Closes several projects at once.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-02
    @arch-tag: ca6395ca-df76-467c-8b46-65f4370d3248
    @cvs-id $Id$
} {
    task_item_id:integer,multiple
    {return_url "index?assignee_id=[ad_conn user_id]"}
} -properties {
} -validate {
} -errors {
}

set number 0

foreach task $task_item_id {
    permission::require_permission \
	-privilege write \
	-object_id $task

    pm::task::close \
        -task_item_id $task

    incr number
}

if {$number > 1} {
    set task_tasks tasks
} else {
    set task_tasks task
} 

ad_returnredirect -message "$number $task_tasks closed" $return_url
