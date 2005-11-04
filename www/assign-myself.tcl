# packages/project-manager/www/assign-myself
ad_page_contract { 
    Assign all the recieved tasks to the recieved role, default to lead.
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    task_item_id:multiple
    {role_id "1"}
    {return_url ""}
}

set user_id [ad_conn user_id]

set page_title "[_ project-manager.Assign_myself]"
set context [list $page_title]

if { ![exists_and_not_null $return_url] } {
    set return_url [get_referrer]
}

# To display the tasks in the ad_form
set show_tasks [list]
foreach task $task_item_id {
    lappend show_tasks "\#$task"
}
set show_tasks [join $show_tasks ", "]

ad_form -name "reassign" -form {
    {task_item_id:text(hidden)
        {value $task_item_id}
    }
    {return_url:text(hidden)
        {value $return_url}
    }
    {show_tasks:text(text)
        {label "[_ project-manager.Tasks]:"}
        {value  $show_tasks}
        {mode display}
    }
    {reassign_party:text(inform)
        {label "[_ project-manager.Reassign]:"}
	{value "[_ project-manager.Myself]"}
    }
} -on_submit {
    
    # We are going to reassign all the checked tasks to the user_id
    foreach task $task_item_id {
        # We need to check if the user_id is not assigned to the task_id as role_id first
	if { ![db_string check_assign { } -default "0"] } {
	    db_dml assign_tasks { }
	}
    }

} -after_submit {
    ad_returnredirect $return_url
}
