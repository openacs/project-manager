# /packages/project-manager/lib/groupmember-list.tcl
#
# author Miguel Marin (miguelmarin@viaro.net)
# author Viaro Netorks www.viaro.net
# creation-date 2005-10-03
#
# Expects:
# groupname       The name of the group to get the members list
# orederby        The orderby variable for orderby clauses
# customer_filter The filter for the customer of the project

set required_param_list [list group_name]
set optional_param_list [list community_id]
set optional_unset_list [list orderby customer_filter package_id]

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

# We get the package_id of the project_manager instance
if {![exists_and_not_null community_id]} {
    set community_id [dotlrn_community::get_community_id]
}

if { ![empty_string_p $community_id] } {
    set package_id [dotlrn_community::get_package_id_from_package_key \
			-package_key project-manager \
			-community_id $community_id]
} else {
    set package_id [ad_conn package_id]
}

# Get the group members list
set group_members_list [group::get_members -group_id $group_id]

set customer_list {}
# Get the customers list associated to this package_id
#set customer_list [list]
#db_foreach get_customers { } {
#    set customer_name [contact::name -party_id $customer_id]
#    lappend customer_list [list $customer_name $customer_id]
#}

template::list::create \
    -name members \
    -multirow members \
    -key project_id \
    -elements {
	name {
	    label "[_ project-manager.Name]:"
	}
	email {
	    label "[_ project-manager.Email]:"
	}
	project_name {
	    label "[_ project-manager.Project]"
	}
	customer {
	    label "[_ project-manager.Customer]:"
	}
	deadline {
	    label "[_ project-manager.Deadline]"
	}
    } \
    -filters {
	customer_filter {
	    label "[_ project-manager.Customer]"
	    values { $customer_list }
	    where_clause { customer_id = :customer_filter }
	}
	package_id {
	    where_clause { proj.object_package_id = :package_id }
	}
    } \
    -orderby_name orderby \
    -orderby {
	deadline {
	    label "[_ project-manager.Deadline_1]"
	    orderby_desc {deadline desc, name desc}
	    orderby_asc {deadline asc, name asc }
	}
    }

# Create the multirow
db_multirow -extend { project_name customer} members get_members { } {
    set project_name [pm::project::name -project_item_id $project_id]
    set customer [contact::name -party_id $customer_id]
}