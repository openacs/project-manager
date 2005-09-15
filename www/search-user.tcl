ad_page_contract {
    Search for a user in the system.

    @author Anny Flores (annyflores@viaro.net)
    @author Viaro Networks www.viaro.net
    

} {
    project_item_id:integer,notnull
    return_url:notnull
}


set project_name [pm::project::name -project_item_id $project_item_id]

set title "[_ project-manager.search_user]"
set context [list [list "one?project_item_id=$project_item_id" "$project_name"] \
		 [list "project-assign-edit?project_item_id=$project_item_id&return_url=$return_url" [_ project-manager.Edit_assignees]] $title]

ad_form -name search_user -form {
    {project_item_id:text(hidden)
	{value $project_item_id}
    }
    {return_url:text(hidden)
	{value $return_url}
    }
    {search_user_id:party_search(party_search),optional
	{label "[_ project-manager.search_user]:"}
    }
} -after_submit {
    ad_returnredirect "project-assign-edit?project_item_id=$project_item_id&search_user_id=$search_user_id&return_url=$return_url"
}
