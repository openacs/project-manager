# /packages/project-manager/www/reports.tcl
ad_page_contract {
    Reports on projects, show the number of projects along with the total and 
    avergage amount they made (aggregated) per year, month, week, day

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Netwroks www.viaro.net

} {
    {day ""}
    {month ""}
    {year ""}
    {last_years "5"}
    {show_p "f"}
    {min_amount "0" }
    {status_id ""}
}

set optional_unset_list [list status_id]

# Check if contacts is installed
set invoices_installed_p [apm_package_installed_p invoices]

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
        if {[empty_string_p [set $optional_unset]]} {
            unset $optional_unset
        }
    }
}

set context [list "[_ project-manager.Projects_reports]"]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set base_url [ad_conn url]
set return_url [ad_return_url]

# For to choose how many last years we want to show
ad_form -name aggregate -form {
    {day:text(hidden)
        {value $day}
    }
    {month:text(hidden)
        {value $month}
    }
    {year:text(hidden)
        {value $year}
    }
    {show_p:text(hidden)
        {value $show_p}
    }
    {last_years:text(text),optional
        {label  "[_ project-manager.last_years]:"}
        {value $last_years}
        {html {size 2}}
        {help_text "[_ project-manager.aggregate_projects]" }
    }
    {min_amount:text(text),optional
	{label "[_ project-manager.Min_amount]"}
	{value $min_amount}
        {html {size 10}}
	{help_text "[_ project-manager.min_amount_help]"}
    }
}

# Get the filter for year month and day
# base url to redirect 
set base reports
set extra_vars [list [list min_amount $min_amount]]
if { [exists_and_not_null status_id] } {
    lappend extra_vars [list status_id $status_id]
}

set ydm_filter [pm::project::year_month_day_filter \
		    -year $year \
		    -month $month \
		    -day $day \
		    -last_years $last_years \
		    -base "reports" \
		    -extra_vars $extra_vars\
		   ]

set status_options [db_list_of_lists get_status {select description, status_id from pm_project_status } ]

# Create the list
template::list::create \
    -name projects \
    -multirow projects \
    -elements {
	title {
	    label "[_ project-manager.Projects]"
	    display_template {
		@projects.title@
		<if @projects.proj_num@ not eq 0>
		<if "$return_url" eq "$base_url">
 		   (<a href="${return_url}?show_p=t" title="[_ project-manager.show_this_projects]">@projects.proj_num@</a>)
		</if>
		<else>
 		   (<a href="${return_url}&show_p=t" title="[_ project-manager.show_this_projects]">@projects.proj_num@</a>)
		</else>
		</if>
	    }
	} 
	amount_total {
	    label "[_ project-manager.Total_amount]"
	}
	planned_end_date {
	    label "[_ project-manager.Planned_end_date]"
	    display_template {
		<center>@projects.planned_end_date@</center>
	    }
	}
    } -filters {
	status_id {
	    label "[_ project-manager.Status]"
	    values $status_options
	    where_clause { p.status_id = :status_id }
	}
    }


# We are going to extend the query according the the sending variables (year, month and day)
set extra_query ""

if { [exists_and_not_null year] } {
    # We get the projects for this year
    append extra_query " and to_char(p.planned_end_date, 'YYYY') = :year"
}

if { [exists_and_not_null month] } {
    # We get the projects for this specific month
    append extra_query " and to_char(p.planned_end_date, 'MM') = :month"
}

if { [exists_and_not_null day] } {
    # We get the projects for this specific day
    append extra_query " and to_char(p.planned_end_date, 'DD') = :day"
}

# We get all the projects
set projects_list [db_list_of_lists get_all_projects " "]

# We create the multirow to show according of the results of the query
 template::multirow create projects title amount_total proj_num planned_end_date

if { [exists_and_not_null year] && [exists_and_not_null month] && [exists_and_not_null day] || $show_p} { 
   # We get only the projects that match the exact date
    foreach project $projects_list {
	set project_item_id [lindex $project 0]
	set title [lindex $project 1]
	set planned_end_date [lindex $project 2]
	set offer_item_id [pm::project::get_iv_offer -project_item_id $project_item_id]
	set offer_id [content::item::get_latest_revision -item_id $offer_item_id]
	
        if { $invoices_installed_p } {
            set billed_p [iv::offer::billed_p -offer_id $offer_id]
            if { $billed_p } {
                set amount_total [db_string get_amount_total { }]
                if { $amount_total >= $min_amount } {
                    template::multirow append projects $title $amount_total 0 $planned_end_date
                }
            }
        }
    }
} else {
    # We accumulate the amount_total and the number of billed projects to show on the list
    set tot_proj_amount 0
    set projects_num 0
    foreach project $projects_list {
	set project_item_id [lindex $project 0]
	set title [lindex $project 1]
	set offer_item_id [pm::project::get_iv_offer -project_item_id $project_item_id]
	set offer_id [content::item::get_latest_revision -item_id $offer_item_id]
        
        if { $invoices_installed_p } {
            set billed_p [iv::offer::billed_p -offer_id $offer_id]
            if { $billed_p } {
                set amount_total [db_string get_amount_total { }]
                if { $amount_total >= $min_amount } {
                    set tot_proj_amount [expr $tot_proj_amount + $amount_total]
                    incr projects_num
                }
            }
        }
    }
    template::multirow append projects "[_ project-manager.Projects]" $tot_proj_amount $projects_num "- - - - - - - - - - -"
}
