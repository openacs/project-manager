# 

ad_page_contract {
    
    Shows all the revisions of a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-30
    @arch-tag: 339a6143-11a3-4f1b-902d-a3cd71f7d531
    @cvs-id $Id$

} {
    project_item_id:integer
} -properties {
    revisions:multirow
} -validate {
} -errors {
}


set title "Project Changes"

set context [list "one?project_item_id=$project_item_id Project" "View Revisions"]


# Project Revisions, using list-builder ---------------------------------

template::list::create \
    -name revisions \
    -multirow revisions \
    -key project_id \
    -elements {
        project_id {
            label "Subject"
            display_col project_name
            link_url_col item_url
            link_html { title "View this revision" }
            display_template {<if @revisions.live_revision@ eq @revisions.project_id@><B>@revisions.project_name@</B></if><else>@revisions.project_name@</else>}
        }
        description {
            label "Description"
            display_template {
                @revisions.description_rich;noquote@
            }
        }
        planned_end_date {
            label "Deadline"
        }
    } \
    -sub_class {
        narrow
    } 


set descriptions [list]

db_multirow -extend { item_url description_rich old_revision_id } revisions project_revisions_query {
} {
    set item_url [export_vars -base "one" -override {{project_item_id $item_id}}  { project_id }]

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



