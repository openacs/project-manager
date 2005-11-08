# packages/project-manager/lib/people.tcl
#
# List of assignees
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c3229143-2307-482b-9f72-e12bd256ac08
# @cvs-id $Id$

foreach required_param {task_id} {
    if {![info exists $required_param]} {
	return -code error "[_ project-manager.lt_required_param_is_a_r]"
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set user_id     [auth::require_login]
set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]

set assignee_add_self_widget "[_ project-manager.Add_myself_as] <form method=\"post\" action=\"task-assign-add\">[export_vars -form {{task_item_id $task_id} user_id return_url}][pm::role::task_select_list -select_name "role_id" -task_item_id $task_id -party_id $user_id]<input type=\"Submit\" value=\"OK\" /></form>"

# Only need a 'remove myself' link if you are already assigned
set assigned_p [pm::task::assigned_p -task_item_id $task_id -party_id $user_id]
if {$assigned_p} {
    set assignee_remove_self_url [export_vars -base task-assign-remove {{task_item_id $task_id} user_id return_url}]
}

# People, using list-builder ---------------------------------

template::list::create \
    -name people \
    -multirow people \
    -key item_id \
    -elements {
        first_names {
            label {
                "[_ project-manager.Who]"
            }
            display_template {
                <if @people.is_lead_p@><i></if>@people.assign_name@<if @people.is_lead_p@></i></if>
            }
        }
        role_id {
            label "[_ project-manager.Role]"
            display_template "@people.one_line@"
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        party_id {}
        task_id {}
        orderby_depend_to {}
        orderby_depend_from {}
    } \
    -orderby {
        default_value role_id,desc
        role_id {
            orderby_asc "role_id asc"
            orderby_desc "role_id desc"
            default_direction asc
        }
        default_value role_id,asc
    } \
    -orderby_name orderby_people \
    -html {
        width 100%
    }

set assign_group_p [parameter::get -parameter "AssignGroupP" -default 0]
set hide_watchers_p [parameter::get -parameter "HideWatchresP" -default 0]

set query_name "task_people_group_query"

db_multirow -extend { assign_name } people $query_name { } {
    if { $hide_watchers_p && $is_observer_p } {
	continue
    }
    if { $assign_group_p } {
        # We are going to show all asignees including groups
        if { [catch {set assign_name [person::name -person_id $party_id] } err] } {
            # person::name give us an error so its probably a group so we get
            # the title
            set assign_name [group::title -group_id $party_id]
        }
    } else {
        if { [catch {set assign_name [person::name -person_id $party_id] } err] } {
            # person::name give us an error so its probably a group, here we don't want
            # to show any group so we just continue the multirow
            continue
        }
    }
}
