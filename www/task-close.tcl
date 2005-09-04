# packages/project-manager/www/task-close.tcl

ad_page_contract {
    
    Close a task and return to the return_url
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-08-04
    @arch-tag: 86200b55-362f-4190-af76-c796abe986c8
    @cvs-id $Id$
} {
    task_item_id
    return_url
} -properties {
} -validate {
} -errors {
}

db_transaction {
    pm::task::close -task_item_id $task_item_id
    set revision_id [pm::task::get_revision_id -task_item_id $task_item_id]

    db_dml complete_task {
	update pm_tasks_revisions
	set percent_complete = '100'
	where task_revision_id = :revision_id
    }

    callback pm::task_edit -package_id [ad_conn package_id] -task_id $task_item_id
}

ad_returnredirect $return_url
