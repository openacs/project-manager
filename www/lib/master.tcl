if [template::util::is_nil context] { set context {}}

set package_url [ad_conn package_url]

if { ![info exists header_stuff] } { set header_stuff {} }

if { ![info exists project_item_id] } { set project_item_id "" }