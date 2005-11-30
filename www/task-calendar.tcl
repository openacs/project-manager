# /packages/room-reservation/www/room-reservations.tcl

ad_page_contract {
    
    Shows tasks on the calendar

    @author Jade Rubick (jader@bread.com)
    @author Deds Castillo (deds@infiniteinfo.com)
    @creation-date 2002-08-28
    @cvs-id $Id$

} {
    {view "month"}
    {date ""}
    {julian_date ""}
    {hide_closed_p "t"}
} -properties {
    title:onevalue
    context:onevalue
    roles:multirow
}

set user_id [auth::require_login]

set date [calendar::adjust_date -date $date -julian_date $julian_date]

set title "Task calendar"
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

set return_url [ad_return_url]

set edit_hidden_vars [export_vars -form {return_url}]

set calendar [pm::calendar::one_month_display \
                  -user_id $user_id \
                  -date $date \
                  -hide_closed_p $hide_closed_p \
                 ]


if {[string is true $hide_closed_p]} {
    set hide_show_closed "Show closed"
    set here [export_vars -base task-calendar {{hide_closed_p f} view date julian_date}]
} else {
    set hide_show_closed "Hide closed"
    set here [export_vars -base task-calendar {{hide_closed_p t} view date julian_date}]
}

# ---------------------------------------------
# make a key of list of roles and abbreviations
# ---------------------------------------------

db_multirow roles roles_and_abbrevs {}


# -------------------------------------
# make a list of users in this subsite.
# -------------------------------------

set users_to_view [pm::calendar::users_to_view]

set subsite_id [ad_conn subsite_id]

set user_group_id [application_group::group_id_from_package_id \
                       -package_id $subsite_id]


db_multirow -extend {checked_p} users users_list {} {
    if {[lsearch $users_to_view $party_id] == -1} {
        set checked_p f
    } else {
        set checked_p t
    }
}
