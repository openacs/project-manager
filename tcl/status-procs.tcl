# 

ad_library {
    
    Procs for project manager status codes and so on.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-21
    @arch-tag: 23a501b5-de19-4d4a-ad9f-57dfa5c8bbd3
    @cvs-id $Id$
}

namespace eval pm::status {}

ad_proc -public pm::status::open_p {
    -task_status_id:required
} {
    Returns t if the task status code is open, f otherwise
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-21
    
    @param task_status_id

    @return 
    
    @error 
} {
    
    set return_val [db_string get_open_p {
        SELECT
        case when status_type = 'c' then 'f' else 't' end
        FROM
        pm_task_status
        WHERE
        status_id = :task_status_id
    }]

    return $return_val
}


ad_proc -public pm::status::default_closed { } {
    Returns a default project_status id that is closed
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-02
    
    @param task_status_id

    @return 
    
    @error 
} {
    
    set return_val [db_string get_closed_status {
        SELECT
        status_id
        FROM
        pm_project_status
        WHERE
        status_type = 'c'
        LIMIT 1
    }]

    return $return_val
}


ad_proc -public pm::status::default_open { } {
    Returns a default project_status id that is open
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-17
    
    @param status_id

    @return 
    
    @error 
} {
    
    set return_val [db_string get_open_status {
        SELECT
        status_id
        FROM
        pm_project_status
        WHERE
        status_type = 'o'
        LIMIT 1
    }]

    return $return_val
}


ad_proc -public pm::status::project_status_select {
} {
    Returns a list of project status codes, suitable for list-builder filters
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @return 
    
    @error 
} {
    return [util_memoize [list pm::status::project_status_select_helper] 300]
}


ad_proc -private pm::status::project_status_select_helper {
} {
    Returns a list of project status codes, suitable for list-builder filters
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @return 
    
    @error 
} {
    set return_list [list]
    db_foreach get_status "select description, status_id from pm_project_status order by status_type desc, description" {
	set description [lang::util::localize $description]
	lappend return_list [list "$description" $status_id]
    }
    return $return_list
}
