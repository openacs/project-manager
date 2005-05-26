# packages/project-manager/lib/forums-portlet.tcl
#
# 
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-26
# @arch-tag: 2e370b1e-543b-41ee-9517-f4445927a286
# @cvs-id $Id$

foreach required_param {forum_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

# Integrate with Forums

if {$forum_id > 1} {
    # Get forum data
    if {[catch {forum::get -forum_id $forum_id -array forum} errMsg]} {
	if {[string equal $::errorCode NOT_FOUND]} {
	    ns_returnnotfound
	    ad_script_abort
	}
	error $errMsg $::errorInfo $::errorCode
    }
    forum::security::require_read_forum -forum_id $forum_id
    forum::security::permissions -forum_id $forum_id permissions
    set package_id [acs_object::get_element -object_id $forum_id -element package_id]
    set base_url [apm_package_url_from_id $package_id]
}

foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}
