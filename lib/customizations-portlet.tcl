# packages/project-manager/lib/project-portlet.tcl
#
# Portlet for short project information
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c502a3ed-d1c0-4217-832a-6ccd86256024
# @cvs-id $Id$


set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]

# -------------------------CUSTOMIZATIONS--------------------------
# If there are customizations, put them in a multirow called custom
# -----------------------------------------------------------------

db_1row custom_query { } -column_array custom 

set customer_link "[site_node::get_package_url -package_key organizations]one?organization_id=$custom(customer_id)"

# end of customizations

