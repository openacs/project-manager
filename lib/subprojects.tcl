# packages/project-manager/lib/subprojects.tcl
# List all subprojects
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: 5b46d737-f74a-4069-9ae8-b833c6017a29
# @cvs-id $Id$

foreach required_param {project_id project_item_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

# Subprojects, using list-builder ---------------------------------

template::list::create \
    -name subproject \
    -multirow subproject \
    -key item_id \
    -elements {
	project_name {
	    label "<#_Subject#>"
	    link_url_col item_url
	    link_html {title "[_ project-manager._View]" }
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
    }

db_multirow -extend {item_url} subproject project_subproject_query {} {

    set item_url [export_vars \
		      -base "one" -override {{project_item_id $item_id}} {project_item_id}]
}


