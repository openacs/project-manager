set user_id [auth::require_login]

set date [calendar::adjust_date -date $date -julian_date $julian_date]
set base_url [ad_conn package_url]project-manager/


set title "Project calendar"
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

set edit_hidden_vars [export_vars -form {return_url}]

set calendar [pm::calendar::one_month_project_display \
                  -user_id $user_id \
                  -date $date \
                  -hide_closed_p $hide_closed_p \
		 ]


if {[string is true $hide_closed_p]} {
    set hide_show_closed "Show closed"
    set here "?hide_closed_p=f&view=$view&date=$date&julian_date=$julian_date#top"
} else {
    set hide_show_closed "Hide closed"
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
set package_id [dotlrn_community::get_package_id_from_package_key -package_key project-manager -community_id [dotlrn_community::get_community_id]]

set users_clause ""

if { ![string eq  [ad_conn package_id] [dotlrn::get_package_id]]} {
    set users_clause "and pa.project_id in (select  p.item_id
          from pm_projectsx p 
          where 
          p.item_id = pa.project_id 
          and p.object_package_id = :package_id)"
} 


db_multirow -extend {checked_p} users assignees {} {
    if {[lsearch $users_to_view $party_id] == -1} {
        set checked_p f
    } else {
        set checked_p t
    }
}
