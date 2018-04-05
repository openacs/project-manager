# /packages/project-manager/lib/customer-group-list.tcl
#
# author Miguel Marin (miguelmarin@viaro.net)
# author Viaro Netorks www.viaro.net
# creation-date 2005-10-05
#
# Displays a list of users that are part of a group specified in group_name
# that have worked on a project for one customer specified in customer_id
#
# Use it as an include in an adp file:
#
# <include src="/packages/project-manager/lib/customer-group-list" 
#               group_name="Freelancer" 
#               customer_id=@customer_id@
#               show_filter_p="t"
#               elements=@elements@
#               cgl_orderby=@cgl_orderby;noquote@
#               page=@page@
#               page_size=@page_size@
#               >
#
# Where:
# group_name    (required)   The name of the group to get the members list
# customer_id   (required)   The customer_id of the customer to get the projects.
# show_filter_p (optional)   If you want to show the filters or not. Default to "t"
# elemetns      (optional)   Elements to show in the list template. If not provided
#                            then will show just: name email project_name deadline.
# cgl_orderby   (optional)   The orderby variable to know how to sort the list
# page          (optional)   The page number of the pagination. Default to "1".
#                            In orther to the pagination work entirelly you need to provide
#                            this variable.
# page_size     (optional)   Number that specified how many rows will be shown on the list.
#                            Default to 5.

set required_param_list [list group_name customer_id]
set optional_param_list [list show_filter_p elements page page_size]
set optional_unset_list [list cgl_orderby]

# Checking required parameters
foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

# We verify if the group exist or not in the system
set group_id [group::get_id -group_name $group_name]
if { [empty_string_p $group_id] } {
    ad_return_complaint 1 "<b>The Group \"$group_name\" doesn't exist on the system</b>"
    ad_script_abort
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

if { ![exists_and_not_null show_filter_p] } {
    set show_filter_p "t"
}

if { ![exists_and_not_null page] } {
    set page 1
}

if { ![exists_and_not_null page_size] } {
    set page_size 5
}

# To see which elements we will show on the list
set rows_list [list]
if { ![exists_and_not_null elements] } {
    set rows_list [list name email project_name deadline]
} else {
    foreach element $elements {
	lappend rows_list $element
	lappend rows_list [list]
    }
}
     
# Get the group members list
set group_members_list [group::get_members -group_id $group_id]

# We set the default format of the table, right now always using "normal"
set format normal

template::list::create \
    -name members \
    -multirow members \
    -selected_format normal \
    -page_query_name get_members_pagination \
    -page_size $page_size \
    -page_flush_p f \
    -key "proj.item_id" \
    -filters {
	page_size
    } -elements {
	name {
	    label "[_ project-manager.Name]:"
	    display_template {
		<a href="/contacts/@members.party_id@">@members.name@</a>
	    }
	}
	email {
	    label "[_ project-manager.Email]:"
	}
	project_name {
	    label "[_ project-manager.Project]"
	    display_template {
		<a href="@members.project_url@">@members.project_name@</a>
	    }
	}
	deadline {
	    label "[_ project-manager.Deadline]"
	}
    } -orderby_name cgl_orderby \
    -orderby {
	deadline {
	    label "[_ project-manager.Deadline_1]"
	    orderby_desc {deadline desc, name desc}
	    orderby_asc {deadline asc, name asc }
	}
    } -formats {
	normal {
	    label "[_ project-manager.Table]"
	    layout table
	    row $rows_list
	}
    }

# Create the multirow
db_multirow -extend { project_name project_url } members get_members { } {
    set project_name [pm::project::name -project_item_id $project_id]
    set project_url "[lindex [site_node::get_url_from_object_id -object_id $object_package_id] 0]one?project_item_id=$project_id"
}
