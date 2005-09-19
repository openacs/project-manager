ad_page_contract {

    Add/edit form for tasks

    Needs to handle the following cases:
    <ul>
    <li> Adding a new task or tasks</li>
    <li> Editing a task or tasks</li>
    <li> Using a process to add new tasks</li>
    </ul>

    @author jader@bread.com
    @creation-date 2003-07-28
    @cvs-id $Id$

    @return context Context bar
    @return title Page title.

    @param task_item_id list of tasks to edit, if there are any
    @project_item_id The project these tasks are assigned to.
    @param process_id The id for the process used, if any
    @param process_task_id The process task IDs if there is a process used.
    @param return_url 
} {
    task_item_id:integer,optional
    {dform:optional "implicit"}
    {project_item_id:integer ""}
    {process_id:integer ""}
    {process_name ""}
    {process_task_id:integer,multiple ""}
    {return_url ""}
    {assignee:array,multiple,optional}
}

# Checking if the variables exist to sent them in the include
if { [exists_and_not_null task_item_id] } {
    set exist_task_p 1
} else {
    set exist_task_p 0
}

if { [array exists assignee] } {
    set exist_assignee_p 1
} else {
    set exist_assignee_p 0
}

# Retrieving the value of the parameter to know which template to call
set template_src [parameter::get -parameter "TaskAdd"]
