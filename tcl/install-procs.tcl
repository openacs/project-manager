ad_library {

    Project manager install library
    
    Procedures that deal with installing, instantiating, mounting.

    @creation-date 2003-01-31
    @author Jade Rubick <jader@bread.com>
    @copied-from Lars Pind <lars@collaboraid.biz>
    @cvs-id $Id$
}


namespace eval pm::install {}


ad_proc -private pm::install::package_instantiate {
    {-package_id:required}
} {
    Package instantiation callback proc. 
} {
    # Create the project repository

    # db_exec_plsql create_project { }
}

ad_proc -private pm::install::package_uninstantiate {
    {-package_id:required}
} {
    Package un-instantiation callback proc
} {
    # Delete the project repository

    # ns_log Debug "pm::install::package_uninstantiate getting folder_id for package_id: $package_id"
    # set folder_id [db_exec_plsql get_folder_id { }]
    # ns_log Debug "pm::install::package_uninstantiate delete folder_id: $folder_id"
    # db_exec_plsql delete_root_folder { }
}
