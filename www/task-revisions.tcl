# 

ad_page_contract {
    
    Shows all the revisions of a task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-30
    @arch-tag: 339a6143-11a3-4f1b-902d-a3cd71f7d531
    @cvs-id $Id$

    @param orderby_revisions specifies how the revisions table will be sorted

} {
    task_id:integer
    orderby_revisions:optional
} -properties {
    revisions:multirow
} -validate {
} -errors {
}


set task_term       [parameter::get -parameter "TaskName" -default "Task Revisions"]

set title "$task_term Changes"

set context [list "task-one?task_id=$task_id $task_term" "View"]


# Task Revisions, using list-builder ---------------------------------

template::list::create \
    -name revisions \
    -multirow revisions \
    -key revision_id \
    -elements {
        revision_id {
            label "Subject"
            display_col task_title
            link_url_col item_url
            link_html { title "View this revision" }
            display_template {<if @revisions.live_revision@ eq @revisions.revision_id@><B>@revisions.task_title@</B></if><else>@revisions.task_title@</else>}
        }
        description {
            label "Description"
            display_template {
                @revisions.description_rich;noquote@
            }
        }
        percent_complete {
            label "Status"
            display_template "@revisions.percent_complete@\%"
        }
        actual_hours_worked {
            label "Hour to date"
            display_template "@revisions.actual_hours_worked@ hrs"
        }
        estimated_hours_work_min {
            label "Work estimate"
            display_template "@revisions.estimated_hours_work_min@ - @revisions.estimated_hours_work_max@ hrs"
        }
        end_date {
            label "Deadline"
        }
    } \
    -sub_class {
        narrow
    } 

set descriptions [list]

db_multirow -extend { item_url description_rich old_revision_id } revisions task_revisions_query {
} {
    set item_url [export_vars -base "task-one" -override {{task_revision_id $revision_id}} -exclude {revision_id} { revision_id task_id}]

    set richtext_list [list $description $mime_type]

    set description_rich [template::util::richtext::get_property html_value $richtext_list]

    set descriptions_length [llength $descriptions]

    # if there isn't any previous items, then we don't have to do a
    # word diff. All the content is new.
    if {$descriptions_length < 1} {
        set description_rich $description_rich
        lappend descriptions "$description_rich"

    } else {

        set old_description [lindex $descriptions [expr [llength $descriptions] - 1]]
        set old_description [ad_html_to_text $old_description]
        lappend descriptions "$description_rich"

        set description_rich [pm::util::word_diff \
                                  -split_by " " \
                                  -old "$old_description" \
                                  -start_old "<strike><font color=\"blue\">" \
                                  -end_old "</font></strike>" \
                                  -start_new "<font color=\"green\">" \
                                  -end_new "</font>" \
                                  -new "[ad_html_to_text $description_rich]" \
                                  -filter_proc ""]

        # set description_rich [ad_html_to_text $description_rich]
        set description_rich [ad_text_to_html -no_quote -includes_html -- $description_rich]

    }

}



