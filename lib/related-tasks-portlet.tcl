# packages/project-manager/lib/related-task-portlet.tcl
#
# Portlet for related task information
#
# @author Timo Hentschel (timo@timohentschel.de)
# @creation-date 2005-06-03
# @arch-tag: c502a3ed-d1c0-4217-832a-6ccd86256024
# @cvs-id $Id$


template::list::create \
    -name related_tasks \
    -multirow related_tasks \
    -key x_task_id \
    -elements {
        x_task_id {
            label "[_ project-manager.ID]"
        }
        title {
            label "[_ project-manager.Task]"
            link_url_col item_url
            link_html { title "[_ project-manager.View_this_task]" }
        }
        slack_time {
            label "[_ project-manager.Slack_1]"
        }
        earliest_start_pretty {
            label "[_ project-manager.ES]"
        }
        earliest_finish_pretty {
            label "[_ project-manager.EF]"
        }
        latest_start_pretty {
            label "[_ project-manager.LS]"
        }
        latest_finish_pretty {
            label "[_ project-manager.LF]"
            display_template {
                <b>@xrefs.latest_finish_pretty@</b>
            }
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        task_id {}
        orderby_people {}
        orderby_depend_to {}
        orderby_depend_from {}
    } \
    -html {
        width 100%
    }

db_multirow -extend { item_url earliest_start_pretty earliest_finish_pretty latest_start_pretty latest_finish_pretty slack_time } related_tasks related_tasks_query {
} {
    set item_url [export_vars -base "task-one" -override {{task_id $x_task_id}}]

    set earliest_start_pretty [lc_time_fmt $earliest_start $fmt]
    set earliest_finish_pretty [lc_time_fmt $earliest_finish $fmt]
    set latest_start_pretty [lc_time_fmt $latest_start $fmt]
    set latest_finish_pretty [lc_time_fmt $latest_finish "$fmt"nn]

    set slack_time [pm::task::slack_time \
                        -earliest_start_j $earliest_start_j \
                        -today_j $today_j \
                        -latest_start_j $latest_start_j]

}
