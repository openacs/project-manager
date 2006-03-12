# 

ad_page_contract {
    
    Synchronizes the projects in logger and project-manager
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-04
    @arch-tag: fc794335-9bb0-4447-92cf-b3c1c69124bd
    @cvs-id $Id$
} {
    {confirmed_p "n"}
} -properties {
} -validate {
} -errors {
}

set title "[_ project-manager.lt_Synchronize_logger_pr]"
set context [list $title]

set logger_URLs [parameter::get -parameter "LoggerURLsToKeepUpToDate" -default ""]

if {[string equal $confirmed_p n]} {
    set confirm_link [export_vars -base logger-sync {{confirmed_p y}}]
} else {

    # projects 
    set projects_list [db_list_of_lists get_projects_not_already_linked {
        SELECT
        p.title as project_name,
        p.description,
        p.creation_user,
        p.item_id as project_item_id,
        p.status_id,
        p.customer_id as organization_id,
        p.logger_project
        FROM
        pm_projectsx p,
        cr_items i
        WHERE 
        i.item_id = p.item_id and
        i.live_revision = p.revision_id
    }]

    foreach project $projects_list {
        set project_name    [lindex $project 0]
        set description     [lindex $project 1]
        set creation_user   [lindex $project 2]
        set project_item_id [lindex $project 3]
        set status_id       [lindex $project 4]
        set organization_id [lindex $project 5]
        set logger_project  [lindex $project 6]

        set active_p [pm::status::open_p -project_status_id $status_id]
        set customer_name [organizations::name -organization_id "$organization_id"]
        if {![empty_string_p $customer_name]} {
            append customer_name " - "
        }

        logger::project::edit \
            -project_id $logger_project \
            -name "$customer_name$project_name" \
            -description "$description" \
            -project_lead $creation_user \
            -active_p $active_p


        foreach url $logger_URLs {
            # get the package_id
            set node_id [site_node::get_node_id -url $url]
            array set node [site_node::get -node_id $node_id]
            set this_package_id $node(package_id)

            # make sure the project_id is not already mapped
            
            set num_exists [db_string already_exists_p "select count(*) from logger_project_pkg_map where project_id = :logger_project and package_id = :this_package_id" -default "0"]

            ns_log Notice "Logger sync: (num_exists: $num_exists) (project: $logger_project package_id: $this_package_id)"

            if {$num_exists < 1} {
                ns_log Notice "Logger sync: Mapping: (project: $logger_project package_id: $this_package_id)"
                logger::package::map_project \
                    -project_id $logger_project \
                    -package_id $this_package_id
            }
        }

    }

    ad_returnredirect -message "[_ project-manager.lt_Logger_projects_synch]" index
}


