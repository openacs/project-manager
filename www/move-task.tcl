ad_page_contract {
    Move one task to another project
    
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    @cration-date 2005-08-10
} {
    task_id:integer,notnull
    search_key:optional
    {search_p "0"}
    {return_url ""}
}

set page_title "[_ project-manager.Move_task]"
set context [list [list "task-one?task_id=$task_id" [_ project-manager.one_task]] $page_title]

set package_id [ad_conn package_id]
set project_item_id [pm::task::project_item_id -task_item_id $task_id]
set user_id [ad_conn user_id]

if { [empty_string_p $return_url] } {
    set return_url one?project_item_id=$project_item_id
}

# We are going to get all projects of the same instance that we are located
set options [list]
db_foreach get_projects { } {
    set project [pm::project::get_project_item_id -project_id $object_id]
    lappend options [list "$object_title" $project]
}

ad_form -name move_task -form {
    {task_id:text(hidden) 
	{value $task_id}
    }
    {return_url:text(hidden) 
	{value $return_url}
    }
    {new_project_id:text(select)
	{label "[_ project-manager.Projects]:"}
	{options { $options }}
	{help_text "[_ project-manager.move_help]"}
    }
} -on_submit {

    # Creating a new task on the selected project_id
    set new_task_item_id [pm::task::move -task_item_id $task_id -project_item_id $new_project_id]

} -after_submit {
    ad_returnredirect -message "Task Item $task_id Move to Project $new_project_id" $return_url
}


# To get projects of other instances in the system using to forms, one for search 
# and the other one for select
if { $search_p } {
    set search_options [list]
    db_foreach get_search_projects { } {
	set project [pm::project::get_project_item_id -project_id $object_id]
	lappend search_options [list "$object_title" $project]
    }
    
    ad_form -name move_task_search -form {
	{task_id:text(hidden) 
	    {value $task_id}
	}
	{return_url:text(hidden) 
	    {value $return_url}
	}
	{search_p:text(hidden)
	    {value 1}
	}
	{search_key:text(hidden)
	    {value $search_key}
	}
	{new_project_id:text(select)
	    {label "[_ project-manager.Projects]:"}
	    {options { $search_options }}
	    {help_text "[_ project-manager.move_help]"}
	}
    }  -on_submit {

	# Creating a new task on the selected project_id
	set new_task_item_id [pm::task::move -task_item_id $task_id -project_item_id $new_project_id]

    } -after_submit {
	ad_returnredirect -message "Task Item $task_id Move to Project $new_project_id" $return_url
    } 
} else {

    # Form to search for projects
    ad_form -name search_projects -form {
	{task_id:text(hidden) 
	    {value $task_id}
	}
	{return_url:text(hidden) 
	    {value $return_url}
	}
	{search_p:text(hidden)
	    {value 1}
	}
	{search_key:text(text),optional
	    {label "[_ project-manager.Project_Search]"}
	    {help_text "[_ project-manager.search_help]"}
	}
    }
}