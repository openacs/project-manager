<?xml version="1.0"?>

<queryset>

<fullquery name="assignee_query">
    <querytext>
	SELECT
		a.party_id,
    		r.role_id
    	FROM
    		pm_project_assignment a,
    		pm_roles r
    	WHERE
    		a.role_id = r.role_id and
    		a.project_id = :project_item_id
   	ORDER BY
    		r.role_id
    </querytext>
</fullquery>

<fullquery name="get_user_fullname">
    <querytext>
	select
		first_names ||' '|| last_name as fullname
	from
		persons
	where
		person_id = :search_user_id
    </querytext>
</fullquery>

<fullquery name="get_group_name">
    <querytext>
	select
		group_name
	from
		groups
	where
		group_id = :search_user_id
    </querytext>
</fullquery>

</queryset>