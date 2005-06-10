# packages/project-manager/lib/project-list.tcl
# List of all projects
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-23
# @arch-tag: 2f586eec-4768-42ef-a09a-4950ac00ddaf
# @cvs-id $Id$

set required_param_list [list package_id]
set optional_param_list [list orderby status_id searchterm bulk_p action_p filter_p base_url]
set optional_unset_list [list assignee_id]

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

if {![info exists format]} {
    set format "normal"
}


# --------------------------------------------------------------- #

set exporting_vars { status_id category_id assignee_id orderby format }
set hidden_vars [export_vars -form $exporting_vars]

# set up context bar
set context [list]

# the unique identifier for this package
set user_id    [ad_maybe_redirect_for_registration]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# root CR folder
set root_folder [pm::util::get_root_folder -package_id $package_id]

# Projects, using list-builder ---------------------------------

# Set status
if {![exists_and_not_null status_id]} {
    set status_where_clause ""
    set status_id ""
} else {
    set status_where_clause {p.status_id = :status_id}
}

# We want to set up a filter for each category tree.

set export_vars [export_vars -form {status_id orderby}]

if {[exists_and_not_null category_id]} {
    set temp_category_id $category_id
    set pass_cat $category_id
} else {
    set temp_category_id ""
    unset category_id
}

set category_select [pm::util::category_selects \
                         -export_vars $export_vars \
                         -category_id $temp_category_id \
                         -package_id $package_id \
                        ] 

set assignees_filter [pm::project::assignee_filter_select -status_id $status_id]

if {![empty_string_p $searchterm]} {

    if {[regexp {([0-9]+)} $searchterm match query_digits]} {
        set search_term_where " (upper(p.title) like upper('%$searchterm%')
 or p.item_id = :query_digits) "
    } else {
        set search_term_where " upper(p.title) like upper('%$searchterm%')"
    }
} else {
    set search_term_where ""
}


set default_orderby [pm::project::index_default_orderby]

if {[exists_and_not_null orderby]} {
    pm::project::index_default_orderby \
        -set $orderby
}

# Get url of the contacts package if it has been mounted for the links on the index page.
set contacts_url [util_memoize [list site_node::get_package_url -package_key contacts]]
if {[empty_string_p $contacts_url]} {
    set contact_column "@projects.customer_name@"
} else {
    set contact_column "<a href=\"${contacts_url}contact?party_id=@projects.customer_id@\">@projects.customer_name@</a>"
}


# Get the rows to display

set row_list "checkbox {}\nproject_name {}\n" 
foreach element $elements {
    append row_list "$element {}\n"
}

if {$bulk_p == 1} {
    set bulk_actions [list "[_ project-manager.Close]" "@{base_url}/bulk-close" "[_ project-manager.Close_project]"] 
} else {
    set bulk_actions [list]
}

if {$actions_p == 1} {
    set actions [list "[_ project-manager.Add_project]" "${base_url}/add-edit" "[_ project-manager.Add_project]" "[_ project-manager.Customers]" "[site_node::get_package_url -package_key contacts]" "[_ project-manager.View_customers]"] 
} else {
    set actions [list]
}

template::list::create \
    -name projects \
    -multirow projects \
    -selected_format $format \
    -key project_item_id \
    -elements {
        project_name {
            label "[_ project-manager.Project_name]"
            link_url_col item_url
            link_html { title "[_ project-manager.lt_View_this_project_ver]" }
        }
        customer_name {
            label "[_ project-manager.Customer]"
            display_template "
<if @projects.customer_id@ not nil>$contact_column</if><else>@projects.customer_name@</else>
"
        }
        earliest_finish_date {
            label "[_ project-manager.Earliest_finish]"
            display_template "<if @projects.days_to_earliest_finish@ gt 1>@projects.earliest_finish_date@</if><else><font color=\"green\">@projects.earliest_finish_date@</font></else>"
        }
        latest_finish_date {
            label "[_ project-manager.Latest_Finish]"
            display_template "<if @projects.days_to_latest_finish@ gt 1>@projects.latest_finish_date@</if><else><font color=\"red\">@projects.latest_finish_date@</font></else>"
        }
        actual_hours_completed {
            label "[_ project-manager.Hours_completed]"
            display_template "@projects.actual_hours_completed@/@projects.estimated_hours_total@"
        }
        category_id {
            display_template "<group column=\"project_item_id\"></group>"
        }
    } \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -sub_class {
        narrow
    } \
    -filters {
        searchterm {
            label "[_ project-manager.Search_1]"
            where_clause {$search_term_where}
        }
        status_id {
            label "[_ project-manager.Status_1]" 
            values {[pm::status::project_status_select]}
            where_clause {$status_where_clause}
        }
        assignee_id {
            label "[_ project-manager.Assignee]"
            values {$assignees_filter}
            where_clause {pa.party_id = :assignee_id}
        }
        category_id {
            label Categories
            where_clause {c.category_id = [join [value_if_exists category_id] ","]}
        }
    } \
    -orderby {
        default_value $default_orderby
        project_name {
            label "[_ project-manager.Project_name]"
            orderby_desc "upper(p.title) desc"
            orderby_asc "upper(p.title) asc"
            default_direction asc
        }
        customer_name {
            label "[_ project-manager.Customer_Name]"
            orderby_desc "upper(o.name) desc, earliest_finish_date desc"
            orderby_asc "upper(o.name) asc, earliest_finish_date asc"
            default_direction asc
        }
        category_id {
            label "[_ project-manager.Categories]"
            orderby_desc "c.category_name desc"
            orderby_asc "c.category_name asc"
            default_direction asc
        }
        earliest_finish_date {
            label "[_ project-manager.Earliest_finish]"
            orderby_desc "p.earliest_finish_date desc"
            orderby_asc "p.earliest_finish_date asc"
            default_direction asc
        }
        latest_finish_date {
            label "[_ project-manager.Latest_finish]"
            orderby_desc "p.latest_finish_date desc"
            orderby_asc "p.latest_finish_date asc"
            default_direction asc
        }
        actual_hours_completed {
            label "[_ project-manager.Hours_completed]"
            orderby_desc "p.actual_hours_completed desc"
            orderby_asc "p.actual_hours_completed asc"
            default_direction asc
        }
    } \
    -formats {
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
    -orderby_name orderby \
    -html {
        width 100%
    }

db_multirow -extend { item_url } projects project_folders {
} {
    set item_url [export_vars -base "${base_url}/one" {project_item_id}]
}

# ------------------------- END OF FILE ------------------------- #
