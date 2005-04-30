ad_page_contract {

    Main view page for projects.
    
    @author jader@bread.com
    @author ncarroll@ee.usyd.edu.au (on first version that used CR)
    @creation-date 2003-05-15
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return projects Multirow data set of projects.
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)

} {
    orderby_project:optional
    {status_id:integer,optional}
    {searchterm ""}
    category_id:multiple,optional
    {format "normal"}
    {assignee_id:integer,optional}
} -properties {

    context:onevalue
    projects:multirow
    write_p:onevalue
    create_p:onevalue
    admin_p:onevalue
    task_term:onevalue
    task_term_lower:onevalue
    project_term:onevalue
    project_term_lower:onevalue
}

# --------------------------------------------------------------- #

# terminology
set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower [parameter::get -parameter "projectname" -default "project"]

set exporting_vars { status_id category_id assignee_id orderby_project format }
set hidden_vars [export_vars -form $exporting_vars]


# set up context bar
set context [list]

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# root CR folder
set root_folder [db_string get_root "select pm_project__get_root_folder (:package_id, 'f')"]

# Projects, using list-builder ---------------------------------

# set default values
if {![exists_and_not_null status_id]} {
    set status_id [pm::project::default_status_open]
}


# We want to set up a filter for each category tree.

set export_vars [export_vars -form {status_id orderby}]

if {[exists_and_not_null category_id]} {
    set temp_category_id $category_id
} else {
    set temp_category_id ""
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

if {[exists_and_not_null orderby_project]} {
    pm::project::index_default_orderby \
        -set $orderby_project
}

# Get url of the organizations package if it has been mounted for the links on the index page.
set organizations_url [util_memoize [list site_node::get_package_url -package_key organizations]]
if {[empty_string_p $organizations_url]} {
    set organization_column "@projects.customer_name@"
} else {
    set organization_column "<a href=\"${organizations_url}one?organization_id=@projects.customer_id@\">@projects.customer_name@</a>"
}


template::list::create \
    -name projects \
    -multirow projects \
    -selected_format $format \
    -key project_item_id \
    -elements {
        project_name {
            label "Project name"
            link_url_col item_url
            link_html { title "View this project version" }
        }
        customer_name {
            label "Customer"
            display_template "
<if @projects.customer_id@ not nil>$organization_column</if><else>@projects.customer_name@</else>
"
        }
        earliest_finish_date {
            label "Earliest finish"
            display_template "<if @projects.days_to_earliest_finish@ gt 1>@projects.earliest_finish_date@</if><else><font color=\"green\">@projects.earliest_finish_date@</font></else>"
        }
        latest_finish_date {
            label "Latest Finish"
            display_template "<if @projects.days_to_latest_finish@ gt 1>@projects.latest_finish_date@</if><else><font color=\"red\">@projects.latest_finish_date@</font></else>"
        }
        actual_hours_completed {
            label "Hours completed"
            display_template "@projects.actual_hours_completed@/@projects.estimated_hours_total@"
        }
        category_id {
            display_template "<group column=\"project_item_id\"></group>"
        }
    } \
    -actions [list "Add project" "add-edit" "Add project" "Customers" "[site_node::get_package_url -package_key organizations]" "View customers"] \
    -bulk_actions [list "Close" "bulk-close" "Close project"] \
    -sub_class {
        narrow
    } \
    -filters {
        searchterm {
            label "Search"
            where_clause {$search_term_where}
        }
        status_id {
            label "Status" 
            values {[pm::status::project_status_select]}
            where_clause {s.status_id = :status_id}
        }
        assignee_id {
            label "Assignee"
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
            label "Project name"
            orderby_desc "upper(p.title) desc"
            orderby_asc "upper(p.title) asc"
            default_direction asc
        }
        customer_name {
            label "Customer Name"
            orderby_desc "upper(o.name) desc, earliest_finish_date desc"
            orderby_asc "upper(o.name) asc, earliest_finish_date asc"
            default_direction asc
        }
        category_id {
            label "Categories"
            orderby_desc "c.category_name desc"
            orderby_asc "c.category_name asc"
            default_direction asc
        }
        earliest_finish_date {
            label "Earliest finish"
            orderby_desc "p.earliest_finish_date desc"
            orderby_asc "p.earliest_finish_date asc"
            default_direction asc
        }
        latest_finish_date {
            label "Latest finish"
            orderby_desc "p.latest_finish_date desc"
            orderby_asc "p.latest_finish_date asc"
            default_direction asc
        }
        actual_hours_completed {
            label "Hours completed"
            orderby_desc "p.actual_hours_completed desc"
            orderby_asc "p.actual_hours_completed asc"
            default_direction asc
        }
    } \
    -formats {
        normal {
            label "Table"
            layout table
            row {
                project_name {}
                customer_name {}
                category_id {}
                earliest_finish_date {}
                latest_finish_date {}
                actual_hours_completed {}
            }
        } 
        csv {
            label "CSV"
            output csv
            page_size 0
            row {
                project_name {}
                customer_name {}
                category_id {}
                earliest_finish_date {}
                latest_finish_date {}
                actual_hours_completed {}
            }
        } 
    } \
    -orderby_name orderby_project \
    -html {
        width 100%
    }

# Note: On oracle it you get "ORA-03113: end-of-file on communication channel"
#       please drop the index cat_object_map_i.  Unique indexes are not allowed in organization index tables

db_multirow -extend { item_url } projects project_folders {
} {
    set item_url [export_vars -base "one" {project_item_id}]
}



list::write_output -name projects


# ------------------------- END OF FILE ------------------------- #
