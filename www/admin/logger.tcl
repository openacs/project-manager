# /project-manager/www/admin/logger.tcl

ad_page_contract {
    
    Sets up which instances of logger to integrate with project-manager
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-21
    @arch-tag: bac17115-5b9e-4b63-adac-8deb6fef3015
    @cvs-id $Id$
} {
    
} -properties {
} -validate {
} -errors {
}

# set up context bar and title
set context [list "Logger integration"]
set title "Administration: setting up logger integration"

set package_id [ad_conn package_id]

set logger_URLs [parameter::get -parameter "LoggerURLsToKeepUpToDate" -default ""]

set possible_URLs [site_node::get_children -all -package_key logger -node_id [site_node::get_node_id -url "/"]]

ad_form -name logger \
    -form {
        acs_object_id_seq:key
    }

set logger_definition ""
set index 0
foreach url $possible_URLs {

    if {[lsearch $logger_URLs $url] >= 0} {
        set value t
    }  else {
        set value ""
    }

    append logger_definition "
            
            {package_url_$url:text(checkbox),optional
                {label \"$url\"} 
                {options {{\"\" \"t\"}}}
                {value $value}
            }
            "

    incr index
}

    ad_form -extend -name logger \
        -form $logger_definition


ad_form -extend -name logger \
    -on_submit {

        # go through each URL, find out if it has been checked, and
        # save it if so.

        set urls_list [list]
        foreach url $possible_URLs {

            set this_value "[set package_url_[set url]]"
            if {[string equal t $this_value]} {
                lappend urls_list $url
            }
        }
        parameter::set_value \
            -package_id $package_id \
            -parameter LoggerURLsToKeepUpToDate \
            -value "$urls_list"

        ad_returnredirect -message "List of integrated logger instances saved" . 

    } \
    -new_data {
    } \
    -edit_data {
    } \
