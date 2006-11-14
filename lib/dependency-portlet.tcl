# packages/project-manager/lib/dependency-portlet.tcl
#
# Portlet for task dependency information
#
# @author Timo Hentschel (timo@timohentschel.de)
# @creation-date 2005-06-03
# @arch-tag: c502a3ed-d1c0-4217-832a-6ccd86256024
# @cvs-id $Id$

set user_id [ad_conn user_id]

if {$type == "to_other"} {
    set query "depend_on_other"
    set orderby_var "orderby_depend_to"
    set headline "[_ project-manager.lt_task_terms_this_depen]"
} else {
    set query "depend_on_this_task"
    set orderby_var "orderby_depend_from"
    set headline "[_ project-manager.lt_task_terms_depending_]"
}

# Dependency info ------------------------------------------------

template::list::create \
    -name dependency \
    -multirow dependency \
    -key d_task_id \
    -elements {
        dependency_type {
            label "[_ project-manager.Type]"
            display_template {
                <if @dependency.dependency_type@ eq start_before_start>
                <img border="0" src="/resources/project-manager/start_before_start.png">
                </if>
                <if @dependency.dependency_type@ eq start_before_finish>
                <img border="0" src="/resources/project-manager/start_before_finish.png">
                </if>
                <if @dependency.dependency_type@ eq finish_before_start>
                <img border="0" src="/resources/project-manager/finish_before_start.png">
                </if>
                <if @dependency.dependency_type@ eq finish_before_finish>
                <img border="0" src="/resources/project-manager/finish_before_finish.png">
                </if>
            }
        }
        d_task_id {
            label "[_ project-manager.Task]"
            display_col task_title
            link_url_col item_url
            link_html { title "[_ project-manager.View_this_task]" }
        }
        percent_complete {
            label "[_ project-manager.Status_1]"
            display_template "@dependency.percent_complete@\%"
        }
        end_date {
            label "[_ project-manager.Deadline_1]"
        }
    } \
    -orderby {
        percent_complete {orderby percent_complete}
        end_date {orderby end_date}
    } \
    -orderby_name $orderby_var \
    -sub_class {
        narrow
    } \
    -filters {
        task_id {}
        orderby_people {}
    } \
    -html {
        width 100%
    }

db_multirow -extend { item_url } dependency $query {
} {
    set item_url [export_vars -base "task-one" -override {{task_id $parent_task_id}} { task_id $d_task_id }]
    # set item_url [export_vars -base "task-one" {{task_id $d_task_id}}]
    set end_date [lc_time_fmt $end_date $fmt]
}
