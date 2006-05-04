ad_page_contract {

    Simple add/edit form for projects

    @author jader@bread.com, ncarroll@ee.usyd.edu.au
    @creation-date 2003-05-15
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.

} {
    project_id:integer,optional
    {dform:optional "project"}
    {project_revision_id ""}
    {project_item_id ""}
    {project_name ""}
    {project_code ""}
    {parent_id ""}
    {goal ""}
    {description:html ""}
    {customer_id ""}
    {planned_start_date ""}
    {planned_end_date ""}
    {deadline_scheduling ""}
    {ongoing_p ""}
    {status_id "1"}
    {extra_data:optional ""}

} -properties {

    context_bar:onevalue
    title:onevalue

}

# We need to know if project_id is sent or not to figure out id we sent it on 
# the include or not
if { [exists_and_not_null project_id] } {
    set project_id_p 1
} else {
    set project_id_p 0
}

# Retrieving the name of the template to call
set template_src [parameter::get -parameter "ProjectAdd"]
