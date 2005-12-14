# Displays list of log entries
#
# Expects:
#   selected_project_id
#   selected_variable_id
#   selected_user_id
#   selected_entry_id
#   start_date_ansi
#   end_date_ansi 
#   projection_value
#   group_by:optional
#   pm_project_id    project manager project ID
#   pm_task_id       project manger task ID


if {![exists_and_not_null pm_task_id]} {
    set pm_task_id ""
}


set current_user_id [ad_conn user_id]
set package_id [ad_conn package_id]

set where_clauses [list]
if { [exists_and_not_null selected_project_id] } {
    # Only selected project
    lappend where_clauses "lp.project_id = :selected_project_id"
} else {
    # All projects mapped to the package
    lappend where_clauses \
        "exists (select 1
                 from logger_project_pkg_map
                 where project_id = lp.project_id
                 and package_id = :package_id
                )"
}


if { [exists_and_not_null selected_variable_id] } {
    db_1row select_variable_info {} -column_array variable

    lappend where_clauses "le.variable_id = :selected_variable_id"
}

if { [exists_and_not_null selected_user_id] } {
    lappend where_clauses "submitter.user_id = :selected_user_id"
}

if { [exists_and_not_null start_date_ansi] } {
    lappend where_clauses "le.time_stamp >= to_date(:start_date_ansi,'YYYY-MM-DD')"
}

if { [exists_and_not_null end_date_ansi] } {
    lappend where_clauses "le.time_stamp <= to_date(:end_date_ansi,'YYYY-MM-DD')"
}

# if pm_task_id is passed in, then we limit what is displayed to that
# project manager task.

if { [exists_and_not_null pm_task_id] } {
    lappend where_clauses "le.entry_id in (select object_id_two from acs_data_links where object_id_one = :pm_task_id)"
}


if { ![exists_and_not_null selected_entry_id] } {
    set selected_entry_id {}
}

set order_by "le.time_stamp desc, ao.creation_date desc"


# If we're grouping by, we should sort by that column first
if { [exists_and_not_null group_by] } {
    switch -exact $group_by {
        user_id {
            set order_by "user_name asc, $order_by"
        }
        project_name {
            set order_by "project_name asc, $order_by"
        }
    }
}

set value_total 0
set value_count 0

set last_group_by_value {}
set value_subcount 0
set value_subtotal 0

db_multirow -extend { subtotal subaverage view_url edit_url delete_url delete_onclick user_chunk selected_p } entries select_entries {} {
    set description [string_truncate -len 50 -- $description]
    set project_name [string_truncate -len 20 -- $project_name]
    set selected_p [string equal $id $selected_entry_id]
    set action_links_list [list]
    set view_url "[ad_conn package_url]log?[export_vars { { entry_id $id } { pm_project_id $pm_project_id } {pm_task_id $pm_task_id} }]"
    set edit_url "[ad_conn package_url]log?[export_vars { { entry_id $id } { edit "t" } {pm_project_id $pm_project_id} {pm_task_id $pm_task_id} }]"
    if { $delete_p } {
        set delete_onclick "return confirm('[_ project-manager.lt_Are_you_sure_you_want_1]);"
        set delete_url "[site_node::get_package_url -package_key logger]log-delete?[export_vars { { entry_id $id } {pm_task_id $pm_task_id} {return_url "[ad_return_url]"} {confirm_p 1} }]"
    } else {
        set delete_url ""
    }
    
    set user_chunk [ad_present_user $user_id $user_name]

    if { [exists_and_not_null group_by] } {
        # Should we reset the subtotal?
        if { ![string equal $last_group_by_value [set $group_by]] } {
            set value_subtotal 0
            set value_subcount 0
        }
        
        # Calculate new subtotal/average
        set value_subtotal [expr $value_subtotal + $value]
        incr value_subcount

        # and store it in the column
        set subtotal $value_subtotal
        set subaverage [expr round(100.0 * $value_subtotal / $value_subcount) / 100.0]

        set last_group_by_value [set $group_by]
    }

    set value_total [expr $value_total + $value]
    incr value_count
}

if { $value_count > 0 } {
    set value_average [expr round(100.0 * $value_total / $value_count) / 100.0] }  {
    set value_average "[_ project-manager.na]"
}

