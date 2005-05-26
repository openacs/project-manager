#

ad_page_contract {
    
    Deletes a task
    
    @author Chris Davis (mcd@daviesinc.com)
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-31
    @arch-tag: af0efc2f-cf78-4f80-a484-1f52f3db6a48
    @cvs-id $Id$
} {
    task_item_id:integer
} -properties {
} -validate {
} -errors {
}

set package_id [ad_conn package_id]

permission::require_permission -privilege "delete" -object_id $task_item_id

set title "[_ project-manager.Delete_task]"
set context [list "[_ project-manager.Delete_task]"]


set action [template::form get_action delete_task]

if {[string equal $action delete]} {

    pm::task::delete -task_item_id $task_item_id
    ad_returnredirect -message "[_ project-manager.lt_Task_task_item_id_Del]" "tasks"
    ad_script_abort

} else {

    set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

    if {[string is true $use_uncertain_completion_times_p]} {
        set hours_work {
            {estimated_hours_work_min:text
                {label "[_ project-manager.Estimated_Hours_Min]"}
            }
            {estimated_hours_work_max:text
                {label "[_ project-manager.Estimated_Hours_Max]"}
            }
        }
    } else {
        set hours_work {
            {estimated_hours_work:text
                {label "[_ project-manager.Estimated_Hours]"}
            }
        }
    }


    set form "
        task_item_id:key
        {task_title:text
            {label \"[_ project-manager.Title_1]"}
        }
        {description:richtext
            {label \"[_ project-manager.Description_2]"}
        }
        $hours_work
        {percent_complete:text
            {label \"[_ project-manager.Percent_Complete]"}
        }
    "
    
    ad_form -name delete_task \
        -edit_request {

            db_1row task_query { }

            set description [list $description $mime_type]

        } \
        -mode display \
        -has_submit 1 \
        -has_edit 1 \
        -actions {{"#project-manager.Delete_this_task#" delete} {"#project-manager.Cancel#" cancel}} \
        -cancel_url "task-one?task_id=$task_item_id" \
        -form $form 

}

