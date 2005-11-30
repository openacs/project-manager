# 

ad_page_contract {
    
    Assigns people to a project based on the assignments for tasks in 
    the project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-28
    @arch-tag: 0ef1b86a-6653-4734-81b9-280c6f71f408
    @cvs-id $Id$
} {
    project_item_id:integer,notnull
    return_url
} -properties {
} -validate {
} -errors {
}

# remove all assignments

set current_assignees [pm::project::assign_remove_everyone \
                           -project_item_id $project_item_id]

# get all task assignments for this project

set assignments_lol [db_list_of_lists get_people {}]

set parties [list]

foreach pair $assignments_lol {

    foreach {party role} $pair {
        
        # set the lowest role someone is assigned as
        if {[string is false [info exists lowest_role($party)]]} {
            set lowest_role($party) $role
        }
        
        if {$lowest_role($party) < $role} {
            set lowest_role($party) $role
        }
        
        # make a list of parties assigned
        if {[lsearch $parties $party] < 0} {
            lappend parties $party
        }
    }
}

# make project assignments

foreach party $parties {

    if {[lsearch $current_assignees $party] > -1} {
        set send_email_p f
    } else {
        set send_email_p t
    }

    pm::project::assign \
        -project_item_id $project_item_id \
        -role_id $lowest_role($party) \
        -party_id $party \
        -send_email_p $send_email_p
}

ad_returnredirect -message "Saved project assignments based on task assignments" [export_vars -base project-assign-edit {project_item_id return_url}]
