ad_library {
    
    Procs of application linking
    
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-05-23
}

namespace eval application_link {}

ad_proc -public application_link::new {
    -this_package_id:required
    -target_package_id:required
} {
    set user_id [ad_conn user_id]
    set id_addr [ad_conn peeraddr]

    db_exec_plsql create_forward_link {}
    db_exec_plsql create_backward_link {}
}

ad_proc -public application_link::delete_links {
    -package_id:required
} {
    set rel_ids [db_list linked_packages {}]

    foreach rel_id $rel_ids {
	relation_remove $rel_id
    }
}

ad_proc -public application_link::get {
    -package_id:required
} {
    return [db_list linked_packages {}]
}

ad_proc -public application_link::get_linked {
    -from_package_id:required
    -to_package_key:required
} {
    return [db_list linked_package {}]
}
