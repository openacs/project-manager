# Author:         Miguel Marin (miguelmarin@viaro.net)
# Author:         Viaro Networs www.viaro.net
# creation_date:  2005-11-11
#
# Description:    Display all projects across all project-manager instances
#                 where a user id is currently working on.
#
# Required Values:
# ---------------
# from_party_id      To get the tasks from.
#
# Order by:
# --------
# ap_orderby  To sort the list using this orderby value
#
# Other Values:
# -------------
# elements         A list of the elements to show in the list.
# format           The format of the listtemplate layout. Default to "normal"
# show_filters_p   Boolean that indicates if you want to show the filters or not
# ped_filter       Show projects that have set the planned_end_date value.

set required_param_list [list from_party_id]
set optional_param_list [list format show_filters_p elements] 
set optional_unset_list [list ped_filter ap_orderby]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

if {![exists_and_not_null ped_filter] } {
    set ped_filter 1
}

if {![info exists format]} {
    set format "normal"
}

set exporting_vars { status_id category_id format }
set hidden_vars [export_vars -form $exporting_vars]


# set up context bar
set context [list]

# the unique identifier for this package
set user_id [ad_maybe_redirect_for_registration]


# Get url of the contacts package if it has been mounted for the links on the index page.
set contacts_url [util_memoize [list site_node::get_package_url -package_key contacts]]
if {[empty_string_p $contacts_url]} {
    set contacts_p 0
    set contact_column "@projects.customer_name@"
} else {
    set contacts_p 1
    set contact_column "<a href=\"${contacts_url}contact?party_id=@projects.customer_id@\">@projects.customer_name@</a>"
}

# Get the rows to display
if { ![exists_and_not_null elements] } {
    set elements [list project_name customer_name status_id planned_end_date]
}

foreach element $elements {
    lappend row_list $element
    lappend row_list [list]
}

set ped_where_clause ""
if { [exists_and_not_null ped_filter] } {
    switch $ped_filter {
	2 {
	    set ped_where_clause ""
	}
	1 {
	    set ped_where_clause "proj.planned_end_date is not null"
	}
	0 {
	    set ped_where_clause "proj.planned_end_date is null"
	}
    }
}

set actions [list]
set bulk_actions [list]

template::list::create \
    -name "projects" \
    -multirow projects \
    -selected_format $format \
    -key project_item_id \
    -row_pretty_plural "Projects" \
    -orderby_name "ap_orderby" \
    -elements {
        project_name {
            label "[_ project-manager.Project_name]"
            link_url_col item_url
            link_html { title "[_ project-manager.lt_View_this_project_ver]" }
        }
        customer_name {
            label "[_ project-manager.Customer]"
            display_template {
		<if @projects.customer_id@ not nil>
		    $contact_column
		</if>
		<else>
		    @projects.customer_name@
		</else>
	    }
        }
	status_id {
	    label "[_ project-manager.Status_1]"
	    display_template {
		<if @projects.status_id@ eq 2>
		    #project-manager.Closed#
		</if>
		<else>
		    #project-manager.Open#
		</else>
	    }
	}
	planned_end_date {
	    label "[_ project-manager.Deadline]"
	    display_template {
		<if @projects.red_title_p@>
		    <font color="red">@projects.planned_end_date@</font>
		</if>
		<else>
		    @projects.planned_end_date@
		</else>
	    }
	}
    } \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -sub_class {
        narrow
    } -filters {
	ped_filter {
	    label "[_ project-manager.Deadline]"
	    values { { [_ project-manager.All] "2"} {[_ project-manager.Yes] "1"} { [_ project-manager.No] "0"}}
	    where_clause $ped_where_clause
	}
    } -orderby {
	default_value planned_end_date
	project_name {
	    label "[_ project-manager.Project_name]"
	    orderby_asc "proj.project_name asc"
	    orderby_desc "proj.project_name desc"
	    default_direction asc
	}
	planned_end_date {
	    label "[_ project-manager.Deadline_1]"
	    orderby_asc "proj.planned_end_date asc"
	    orderby_desc "proj.planned_end_date desc"
	    default_direction desc
	}
    } -formats {
        normal {
            label "[_ project-manager.Table]"
            layout table
            row $row_list
        } 
        csv {
            label "[_ project-manager.CSV]"
            output csv
            page_size 0
            row $row_list
        } 
    } \
    -html {
        width 100%
    }

db_multirow -extend { item_url customer_name red_title_p } "projects" projects { } {
    acs_object::get -object_id $project_item_id -array project_array
    set base_url [lindex [site_node::get_url_from_object_id -object_id $project_array(package_id)] 0]
    set item_url [export_vars -base "${base_url}one" {project_item_id}]

    set customer_name ""
    if { $contacts_p } {
	set customer_name [contact::name -party_id $customer_id]
    }

    set red_title_p 0
    set sysdate [dt_sysdate -format "%Y-%m-%d %H:%M:%S"]
    if { $sysdate > $planned_end_date } {
	set red_title_p 1
    }
}

ad_return_template

