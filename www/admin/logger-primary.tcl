# /project-manager/www/admin/logger-primary.tcl

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
set title "Administration: setting up primary logger instance"

set package_id [ad_conn package_id]

set possible_URLs [parameter::get \
		       -parameter "LoggerURLsToKeepUpToDate" -default ""]

set logger_primary [parameter::get \
			-parameter "LoggerPrimaryURL" -default ""]

ad_form -name logger \
    -form {
        acs_object_id_seq:key
    }

set logger_options [list]

foreach url $possible_URLs {

    lappend logger_options [list $url $url]
}

set logger_definition {
    {package_url:text(select)
	{label "[_ project-manager.lt_Primary_logger_instan]"} 
	{options {$logger_options}} 
	{value $logger_primary}
    }
}

ad_form -extend -name logger \
    -form $logger_definition

ad_form -extend -name logger \
    -on_submit {

	parameter::set_value \
            -package_id $package_id \
            -parameter LoggerPrimaryURL \
            -value "$package_url"

	ad_returnredirect -message "[_ project-manager.lt_Primary_logger_instan_1]" .
    } \
    -new_data {
    } \
    -edit_data {
    }
