ad_page_contract {

    Form to add in assignments to process tasks

    @author jader@bread.com
    @creation-date 2003-09-25
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.
    @return process_id The process we're adding/editing tasks for

    @return num used as a multirow datasource to iterate over the form elements

    @param process_id The process that we're adding or editing items for.
    @param process_task_id The tasks we're creating and adding assignments for
    @param use_dependency A list of tasks that will need dependencies. Needs to be passed to the depedency page.
} {

    my_key:integer,optional
    process_id:integer,notnull
    process_task_id:notnull,multiple
    {use_dependency:multiple ""}
    role_id:array,optional
    party_id:array,optional

} -properties {

    context_bar:onevalue
    title:onevalue
    process_id:onevalue
    tasks:multirow
    num:multirow
    task_term_lower:onevalue

} -validate {
} -errors {
}

# --------------------------------------------------------------- #


# hack to get around lack of multiple hidden support with ad_form

set process_task_id_pass $process_task_id
set process_task_id_pass [string map {"-" " "} $process_task_id_pass]
set process_task_id      $process_task_id_pass

set use_dependency_pass  $use_dependency
set use_dependency_pass  [string map {"-" " "} $use_dependency_pass]
set use_dependency       $use_dependency_pass


# terminology
set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]


# the unique identifier for this package
set package_id [ad_conn package_id]
set subsite_id [ad_conn subsite_id]
set user_id    [ad_maybe_redirect_for_registration]

set user_group_id [application_group::group_id_from_package_id \
                       -package_id $subsite_id]


# permissions and more

set title "Add a process $task_term_lower (assignment)"
set context_bar [ad_context_bar [list "processes?process_id=$process_id" "Processes"] "Add assignment"]
permission::require_permission -party_id $user_id -object_id $package_id -privilege create


set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

db_multirow tasks get_tasks { 
    set description [ad_text_to_html -- $description]
}



# create a multirow we can use to iterate
template::multirow create num number 

# currently hardcoded the number of assignments

for {set i 0} {$i <= 5} {incr i} {
    template::multirow append num $i 
}



set users_lofl "{{--Select Person--} {}} "
append users_lofl [db_list_of_lists get_users { }]


set roles_lofl "{{--Select Role--} {}} "
append roles_lofl [db_list_of_lists get_roles { }]


set process_task_id_pass $process_task_id
set process_task_id_pass [string map {" " "-"} $process_task_id]

set use_dependency_pass $use_dependency
set use_dependency_pass [string map {" " "-"} $use_dependency]


ad_form -name add_edit -form {
    
    my_key:key(acs_object_id_seq)

    {process_id:text(hidden)
        {value $process_id}}

    {process_task_id:text(hidden)
        {value $process_task_id_pass}}

    {use_dependency:text(hidden)
        {value $use_dependency_pass}}
    
   
} -on_submit {

    set user_id [ad_conn user_id]
    set peeraddr [ad_conn peeraddr]

} -new_data {

    #role_id 
    #party_id

    if {[info exists role_id]} {
        
        set searchToken [array startsearch role_id]
        
        while {[array anymore role_id $searchToken]} {
            
            set keyname   [array nextelement role_id $searchToken]
            set keyvalu   $role_id($keyname)
            
            # keyname looks like 2308.1 - 2308.10
            # first element is task_id, second is 1-10
            # if keyvalu is not empty, then we pay attention to it.

            if {[exists_and_not_null keyvalu]} {

                regexp {(.*)\.(.*)} $keyname match task_id_val num_value

                set assignment_role($task_id_val,$num_value) $keyvalu

            }            
        }
        
    }

    set party_list [list]

    if {[info exists party_id]} {
        
        set searchToken [array startsearch party_id]
        
        while {[array anymore party_id $searchToken]} {
            
            set keyname   [array nextelement party_id $searchToken]
            set keyvalu   $party_id($keyname)
            
            # keyname looks like 2308.1 - 2308.10
            # first element is task_id, second is 1-10
            # if keyvalu is not empty, then we pay attention to it.

            if {[exists_and_not_null keyvalu]} {

                regexp {(.*)\.(.*)} $keyname match task_id_val num_value

                set assignment_party($task_id_val,$num_value) $keyvalu

                lappend party_list "$task_id_val,$num_value"

            }            
        }
      
    }

    set process_task_id_pass $process_task_id
    set process_task_id_pass [string map {"-" " "} $process_task_id_pass]
    set process_task_id      $process_task_id_pass

    db_dml delete_assignments { }

    foreach pl $party_list {

        regexp {(.*),(.*)} $pl match task_id_v num_value

        set t_id  $task_id_v
        set r_id  $assignment_role($pl)
        set p_id  $assignment_party($pl)

        db_dml add_assignment { }

    }
        
} -edit_data {

    # do something
    #role_id 
    #party_id

    if {[info exists role_id]} {
        
        set searchToken [array startsearch role_id]
        
        while {[array anymore role_id $searchToken]} {
            
            set keyname   [array nextelement role_id $searchToken]
            set keyvalu   $role_id($keyname)
            
            # keyname looks like 2308.1 - 2308.10
            # first element is task_id, second is 1-10
            # if keyvalu is not empty, then we pay attention to it.

            if {[exists_and_not_null keyvalu]} {

                regexp {(.*)\.(.*)} $keyname match task_id_val num_value

                set assignment_role($task_id_val,$num_value) $keyvalu

            }            
        }
        
    }

    set party_list [list]

    if {[info exists party_id]} {
        
        set searchToken [array startsearch party_id]
        
        while {[array anymore party_id $searchToken]} {
            
            set keyname   [array nextelement party_id $searchToken]
            set keyvalu   $party_id($keyname)
            
            # keyname looks like 2308.1 - 2308.10
            # first element is task_id, second is 1-10
            # if keyvalu is not empty, then we pay attention to it.

            if {[exists_and_not_null keyvalu]} {

                regexp {(.*)\.(.*)} $keyname match task_id_val num_value

                set assignment_party($task_id_val,$num_value) $keyvalu

                lappend party_list "$task_id_val,$num_value"

            }            
        }
      
    }

    set process_task_id_pass $process_task_id
    set process_task_id_pass [string map {"-" " "} $process_task_id_pass]
    set process_task_id      $process_task_id_pass

    db_dml delete_assignments { }

    foreach pl $party_list {

        regexp {(.*),(.*)} $pl match task_id_v num_value

        set t_id  $task_id_v
        set r_id  $assignment_role($pl)
        set p_id  $assignment_party($pl)

        db_dml add_assignment { }

    }
        
} -after_submit {

    # for some reason this hack is necessary here

    set process_task_id_pass $process_task_id
    set process_task_id_pass [string map {"-" " "} $process_task_id_pass]
    set process_task_id      $process_task_id_pass


    #set task_revisions $revision_has_dependencies

    ad_returnredirect "process-dependency-add-edit?[export_vars -url {process_task_id:multiple process_id use_dependency:multiple}]"
    ad_script_abort
}


# we create a terrible monster array

foreach tiid $process_task_id {

    set roles_values [db_list_of_lists get_current_roles { }]
    set users_values [db_list_of_lists get_current_users { }]

    set users_length [string length $users_values]
    set roles_length [string length $roles_values]

    for {set i 0} {$i <= 10} {incr i} {

        if {$i < $users_length && $i < $roles_length} {
            set uv [lindex $users_values $i]
            set rv [lindex $roles_values $i]
        } else {
            set uv ""
            set rv ""
        }

        ad_form -extend -name add_edit -form \
            [list \
                 [list \
                      party_id.$tiid.$i:text(select) \
                      {label "Assignments \#$i $tiid"} \
                      {options {[set users_lofl]}} \
                      {values $uv} \
                     ] \
                 [list \
                      role_id.$tiid.$i:text(select) \
                      {label "Role \#$i $tiid"} \
                      {options {[set roles_lofl]}} \
                      {values $rv} \
                     ] \
                ] 
        
    }
}


