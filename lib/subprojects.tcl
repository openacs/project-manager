# packages/project-manager/lib/subprojects.tcl
# List all subprojects
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: 5b46d737-f74a-4069-9ae8-b833c6017a29
# @cvs-id $Id$

foreach required_param {} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {project_id project_item_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

if {[empty_string_p $project_item_id]} {
    if {[empty_string_p $project_id]} {
        return -code error "You have to provide either project_id or project_item_id"
    } else {
        set project_item_id [pm::project::get_project_item_id -project_id $project_id]
    }
}

if {![exists_and_not_null fmt]} {
    set fmt "%x"
}
if {![exists_and_not_null row_list]} {
    set row_list {project_name {} planned_end_date {} actual_hours_completed {}}
}

set user_id [auth::require_login]
set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]
# Subprojects, using list-builder ---------------------------------

template::list::create \
    -name subproject \
    -multirow subproject \
    -key item_id \
    -selected_format table \
    -elements {
	project_name {
	    label "[_ project-manager.Subject]"
	    link_url_col item_url
	    link_html {title "[_ project-manager._View]" }
	}
	planned_end_date {
	    label "[_ project-manager.Deadline]"
	}
	actual_hours_completed {
	    label "[_ project-manager._Hours]"
	}
    } \
    -sub_class {
	narrow
    } \
    -orderby {
	project_name {orderby project_name}
	default_value project_name,desc
    } \
    -orderby_name orderby_subproject \
    -html {
	width 100%
    } -formats {
	table {
	    label "[_ project-manager.Table]"
	    layout table
	    row $row_list
	}
    }

db_multirow -extend {item_url} subproject project_subproject_query {} {
    set planned_end_date [lc_time_fmt $planned_end_date $fmt]

    set item_url [export_vars \
		      -base "$base_url/one" -override {{project_item_id $item_id}} {project_item_id}]
}


