# packages/project-manager/lib/forums-portlet.tcl
#
# 
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-26
# @arch-tag: 2e370b1e-543b-41ee-9517-f4445927a286
# @cvs-id $Id$

foreach required_param {folder_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}


set package_id [acs_object::get_element -object_id $folder_id -element package_id]
set base_url [apm_package_url_from_id $package_id]
