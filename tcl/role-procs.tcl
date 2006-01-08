#

ad_library {
    
    Procs for roles
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-05
    @arch-tag: 226cb104-9e32-4de3-9f93-ab96e239ca93
    @cvs-id $Id$
}


namespace eval pm::role {}

ad_proc -public pm::role::default {
} {
    Gets the default role. This is pretty much random, but the first 
    role selected
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-05
    
    @return role_id
    
    @error -1 if there is an error.
} {
    set returnval [db_string get_default "select role_id from pm_roles limit 1" -default "-1"]
    return $returnval
}


ad_proc -public pm::role::select_list_filter {} {
    Returns a select list.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @return

    @error 
} {
    return [lang::util::localize_list_of_lists -list [util_memoize [list pm::role::select_list_filter_not_cached] 300]]
}


ad_proc -private pm::role::select_list_filter_not_cached {} {
    Returns a select list. Used so pm::role::select_list can be cached.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11

    @return

    @error
} {
    return [db_list_of_lists get_roles "
                SELECT
                one_line,
                role_id
                FROM
                pm_roles
                ORDER BY
                role_id"]
}


ad_proc -public pm::role::select_list {
    {-select_name:required}
} {
    Returns a select list, suitable for use in an HTML form.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11

    @return

    @error
} {
    set select_list "<select name=\"$select_name\">"

    set select_list_options [pm::role::select_list_filter]

    foreach option $select_list_options {
        set description [lindex $option 0]
        set value       [lindex $option 1]
        append select_list "<option value=\"$value\">$description</option>"
    }

    append select_list "</select>"

    return $select_list
}


ad_proc -public pm::role::project_select_list_filter {
    -project_item_id:required
    -party_id:required
} {
    Returns a select list.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11

    @param project_item_id

    @param party_id

    @return
    
    @error
} {
    return [util_memoize [list pm::role::project_select_list_filter_not_cached -project_item_id $project_item_id -party_id $party_id] 300]
}


ad_proc -private pm::role::project_select_list_filter_not_cached {
    -project_item_id:required
    -party_id:required
} {
    Returns a select list. Used so pm::role::project_select_list can be cached.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11

    @param project_item_id

    @param party_id

    @return

    @error
} {
    return [db_list_of_lists get_roles "
                SELECT
                one_line || ' (' || substring(one_line from 1 for 1) || ')' as one_line,
                role_id
                FROM
                pm_roles as r
                WHERE NOT EXISTS
                    (SELECT 1
                     FROM
                     pm_project_assignment as pa
                     WHERE
                     r.role_id = pa.role_id and
                     pa.project_id = :project_item_id and
                     pa.party_id = :party_id)
                ORDER BY
                role_id"]
}


ad_proc -public pm::role::project_select_list {
    {-select_name:required}
    {-project_item_id:required}
    {-party_id:required}
} {
    Returns a select list, suitable for use in an HTML form.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11

    @return

    @error
} {
    set select_list "<select name=\"$select_name\">"

    set select_list_options [pm::role::project_select_list_filter -project_item_id $project_item_id -party_id $party_id]

    foreach option $select_list_options {
        set description [lindex $option 0]
        set value       [lindex $option 1]
        append select_list "<option value=\"$value\">$description</option>"
    }

    append select_list "</select>"

    return $select_list
}


ad_proc -public pm::role::task_select_list_filter {
    -task_item_id:required
    -party_id:required
} {
    Returns a select list.

    @author Richard Hamilton (ricky.hamilton@btopenworld.com)
    @creation-date 2004-12-18

    @param task_item_id

    @param party_id

    @return

    @error
} {
    return [util_memoize [list pm::role::task_select_list_filter_not_cached -task_item_id $task_item_id -party_id $party_id] 300]
}


ad_proc -private pm::role::task_select_list_filter_not_cached {
    -task_item_id:required
    -party_id:required
} {
    Returns a select list. Used so pm::role::task_select_list can be cached.

    @author Richard Hamilton (ricky.hamilton@btopenworld.com)
    @creation-date 2004-12-18

    @param task_item_id

    @param party_id

    @return

    @error
} {
    return [db_list_of_lists get_roles "
                SELECT
                one_line || ' (' || substring(one_line from 1 for 1) || ')' as one_line,
                role_id
                FROM
                pm_roles as r
                WHERE NOT EXISTS
                    (SELECT 1
                     FROM
                     pm_task_assignment as ta
                     WHERE
                     r.role_id = ta.role_id and
                     ta.task_id = :task_item_id and
                     ta.party_id = :party_id)
                ORDER BY
                role_id"]
}


ad_proc -public pm::role::task_select_list {
    {-select_name:required}
    {-task_item_id:required}
    {-party_id:required}
} {
    Returns a select list, suitable for use in an HTML form.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11

    @return

    @error
} {
    set select_list "<select name=\"$select_name\">"

    set select_list_options [pm::role::task_select_list_filter -task_item_id $task_item_id -party_id $party_id]

    foreach option $select_list_options {
        set description [lindex $option 0]
        set value       [lindex $option 1]
        append select_list "<option value=\"$value\">$description</option>"
    }

    append select_list "</select>"

    return $select_list
}


ad_proc -public pm::role::name {
    -role_id:required
} {
    Returns the one_line for the role from the role_id

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-08

    @param role_id

    @return one_line
    
    @error 
} {
    return [util_memoize [list pm::role::name_not_cached -role_id $role_id]]
}


ad_proc -public pm::role::name_not_cached {
    -role_id:required
} {
    Returns the one_line for the role from the role_id

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-08
    
    @param role_id

    @return one_line

    @error 
} {
    return [db_string get_one_line {
        SELECT
        one_line
        FROM
        pm_roles
        WHERE
        role_id = :role_id
    } -default "error"]
}
