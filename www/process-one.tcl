ad_page_contract {
    Main view page for one process

    @author jader@bread.com
    @creation-date 2003-09-25
    @cvs-id $Id$

    @param process_id The process we're looking at.

    @return process_id the id for the process
    @return context_bar Context bar.
    @return use_link the link to use this process

} {

    process_id:integer,notnull
    orderby:optional
    {project_item_id ""}
    
} -properties {
    process_id:onevalue
    context_bar:onevalue
    use_link:onevalue
} -validate {
} -errors {
    process_id:notnull {You must specify a process to use. Please back up and select a process}
}

# --------------------------------------------------------------- 

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]

set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

# set up context bar, needs parent_id

set context_bar [ad_context_bar [list "processes?process_id=$process_id" "[_ project-manager.Processes]"] "[_ project-manager.One]"]

set use_link "<a href=\"[export_vars -base task-select-project {process_id project_item_id}]\"><img border=\"0\" src=\"/resources/acs-subsite/go.gif\"></a>"


set elements \
    [list \
         one_line {
             label "[_ project-manager.Subject_1]"
             display_template {<a href="process-task-add-edit?process_id=[set process_id]&process_task_id=@tasks.process_task_id@">@tasks.one_line@</a>
                 <if @tasks.dependency_type@ eq start_before_start>
                 <img border="0" src="/resources/project-manager/start_before_start.png">
                 </if>
                 <if @tasks.dependency_type@ eq start_before_finish>
                 <img border="0" src="/resources/project-manager/start_before_finish.png">
                 </if>
                 <if @tasks.dependency_type@ eq finish_before_start>
                 <img border="0" src="/resources/project-manager/finish_before_start.png">
                 </if>
                 <if @tasks.dependency_type@ eq finish_before_finish>
                 <img border="0" src="/resources/project-manager/finish_before_finish.png">
                 </if>
             }
         } \
         description {
             label "[_ project-manager.Description]"
         } \
         person_id {
             label "[_ project-manager.Lead]"
             display_template {
                 <group column="process_task_id">
                 <i>@tasks.first_names@ @tasks.last_name@</i><br />
                 </group>
             }
         }]    


# Process tasks, using list-builder ---------------------------------

template::list::create \
    -name tasks \
    -multirow tasks \
    -key process_task_id \
    -elements $elements \
    -orderby {
        default_value ordering,asc
        ordering {
            label "[_ project-manager.Order]"
            orderby_asc "t.ordering, t.process_task_id, p.first_names, p.last_name"
            orderby_desc "t.ordering desc, t.process_task_id desc, p.first_names, p.last_name"
            default_direction asc
        }
    } \
    -bulk_actions [list \
		   "[_ project-manager.Use]" "task-select-project" "[_ project-manager.Use_process]" \
		   "[_ acs-kernel.common_Edit]" "process-task-add-edit" "[_ project-manager.Edit_tasks]" \
		   "[_ project-manager.Delete]" "process-task-delete" "[_ project-manager.Delete_tasks]" \
		   ]\
    -bulk_action_export_vars {
        process_id
        project_item_id
    } \
    -sub_class {
        narrow
    } \
    -filters {
        process_id {}
    } \
    -html {
        width 100%
    }


db_multirow -extend { item_url } tasks task_query {
} {
}

