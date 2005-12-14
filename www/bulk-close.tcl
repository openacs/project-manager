# /packages/project-manager/www/bulk-close.tcl 
ad_page_contract {
    
    Closes several projects at once.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-02
    @arch-tag: ca6395ca-df76-467c-8b46-65f4370d3248
    @cvs-id $Id$
} {
    project_item_id:integer,multiple
    {return_url "index?assignee_id=[ad_conn user_id]"}
    action:integer,optional
    {show_alert_p 0}
} -properties {
} -validate {
} -errors {
}

set page_title [_ project-manager.bulk_close_projects]
set context [list $page_title]

permission::require_permission \
    -privilege write \
    -object_id [ad_conn package_id] \

set close_status_id [pm::project::default_status_closed]

set alert_projects [list]

if { ![exists_and_not_null action] } {
    foreach project $project_item_id {
	# We get all the subprojects and check if all of them have status closed
	set subprojects [pm::project::get_all_subprojects -project_item_id $project]
	if { [llength $subprojects] > 0 } {
	    set closed_p [pm::project::check_projects_status \
			      -projects $subprojects \
			      -status_id $close_status_id]
	} else {
	    set closed_p 1
	}
	if { !$closed_p } {
	    set show_alert_p 1
	    lappend alert_projects $project
	}
    }
}

if { $show_alert_p } {
    set show_projects "\#"
    append show_projects [join $alert_projects ", \#"]

    ad_form -name alert -form {
	{alert_projects:text(inform) 
	    {label "[_ project-manager.Projects]:"}
	    {value $show_projects}
	}
	{return_url:text(hidden) 
	    {value $return_url}
	}
	{project_item_id:integer(hidden) 
	    {value $project_item_id}
	}
	{show_alert_p:text(hidden)
	    {value $show_alert_p}
	}
	{action:text(radio)
	    {label "[_ project-manager.Action_to_take]"}
	    {options { {"[_ project-manager.Proceed]" 1}  {"[_ project-manager.Proceed_with_closing]" 2} {"[_ project-manager.Cancel]" 3}}}
	    {value 2}
	}
    } -on_submit {
	switch $action {
	    1 {
		# We close just the projects and leave the subprojects as it is
		set number 0
		foreach project $project_item_id {
		    pm::project::close -project_item_id $project	
		    incr number
		}
		
		if {$number > 1} {
		    set project_projects projects
		} else {
		    set project_projects project
		}
		ad_returnredirect -message "$number $project_projects closed" $return_url
	    }
	    2 {
		# We close all projects and subprojects
		set number 0
		foreach project $project_item_id {
		    set subprojects [pm::project::get_all_subprojects -project_item_id $project]
		    foreach sub $subprojects {
			pm::project::close -project_item_id $sub				
			incr number
		    }
		    pm::project::close -project_item_id $project
		    incr number
		}
		
		if {$number > 1} {
		    set project_projects projects
		} else {
		    set project_projects project
		}
		ad_returnredirect -message "$number $project_projects closed" $return_url
	    }
	    3 {
		# No changes made to projects
		ad_returnredirect -message "0 projects closed" $return_url
	    }
	}
    }
} else {
    # There are no unclosed subprojects, just close the projects
    set number 0
    foreach project $project_item_id {
	pm::project::close -project_item_id $project	
	incr number
    }
    
    if {$number > 1} {
	set project_projects projects
    } else {
	set project_projects project
    }

    ad_returnredirect -message "$number $project_projects closed" $return_url
}
