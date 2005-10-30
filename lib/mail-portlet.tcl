# packages/project-manager/lib/mail-portlet.tcl
#
# Portlet to show projec e-mail messages
#
# @author Miguel Marin (miguelmarin@viaro.net)
# @author Viaro Networks www.viaro.net
# @creation-date 2005-05-01

foreach optional_param {page page_size show_filters_p elements} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]
set dotlrn_installed_p [apm_package_installed_p dotlrn]

if { $dotlrn_installed_p } {
    set community_id [dotlrn_community::get_community_id]
    if { ![empty_string_p $community_id] } {
        set package_id [dotlrn_community::get_package_id_from_package_key \
                            -package_key project-manager \
                            -community_id $community_id]
    } else {
        set package_id [ad_conn package_id]
    }
} else {
    set package_id [ad_conn package_id]
}
