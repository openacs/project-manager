set user_id [auth::require_login]

set date [calendar::adjust_date -date $date -julian_date $julian_date]
set base_url [ad_conn package_url]

set title "#project-manager.Task_calendar#"
set context [list $title]
set header_stuff "
<style type=\"text/css\">
.calendar-item {
    font-family: Arial, Helvetica, sans-serif;
}

.calendar-item ul {
    color: \#999;
    display: inline;
    padding-left: 0em;
}

.calendar-item li {
    color: \#999;
    display: inline;
    font-size: 80%;
}

.calendar-item blockquote {
    color: \#999;
    display: block;
    margin: 0em 0em 0.5em 0em;
    font-size: 75%;
}

.calendar-item p {
    border-top: thin dotted grey;
}

.calendar-item strike {
    color: \#bbb;
    text-decoration: line-through;
}

</style>"

set return_url [ad_return_url]\#top

set edit_hidden_vars [export_vars -form {return_url {new_tasks "0"}}]
set users_clause ""

# Shall we hide observers ?
if {![exists_and_not_null hide_observer_p]} {
    set hide_observer_p "f"
}

if { ![exists_and_not_null package_id]} {
    set calendar [pm::calendar::one_month_display \
		      -user_id $user_id \
		      -date $date \
		      -hide_observer_p $hide_observer_p \
		      -hide_closed_p $hide_closed_p \
		      -display_p $display_p \
		     ]
    
    # Figure out all the PM package ids
    set package_ids ""
    foreach package_id [apm_package_ids_from_key -package_key "project-manager"] {
	if {![string eq  [ad_conn package_id] $package_id]} {
	    lappend package_ids $package_id
	}
    }

    if {$package_ids ne ""} {
	set users_clause "and pa.project_id in (select item_id
          from cr_items i, acs_objects o
          where 
          i.item_id = o.object_id
          and i.content_type = 'pm_project'
          and o.package_id in ([template::util::tcl_to_sql_list $package_ids]))"
    }
    
    
} else {
    set calendar [pm::calendar::one_month_display \
		      -user_id $user_id \
		      -date $date \
		      -hide_closed_p $hide_closed_p \
		      -hide_observer_p $hide_observer_p \
		      -display_p $display_p \
		      -package_id $package_id \
		     ]
}


if {[string is true $hide_closed_p]} {
    set hide_show_closed "#project-manager.Show_closed#"
    set here "?hide_closed_p=f&view=$view&date=$date&julian_date=$julian_date#top"
} else {
    set hide_show_closed "#project-manager.Hide_closed#"
    set here "?hide_closed_p=t&view=$view&date=$date&julian_date=$julian_date#top"
}

# ---------------------------------------------
# make a key of list of roles and abbreviations
# ---------------------------------------------

db_multirow roles roles_and_abbrevs {
    SELECT
    one_line as role,
    substring(one_line from 1 for 1) as abbreviation
    FROM
    pm_roles
}


# -------------------------------------
# make a list of users in this subsite.
# -------------------------------------

set users_to_view [pm::calendar::users_to_view]



db_multirow -extend {checked_p} users assignees {} {
    if {[lsearch $users_to_view $party_id] == -1} {
        set checked_p f
    } else {
        set checked_p t
    }
}
