<?xml version="1.0"?>
<queryset>

<fullquery name="update_context_id">
    <querytext>	
	update ratings 
	set context_object_id = :context_object_id 
	where rating_id = :rating_id
    </querytext>
</fullquery>

<fullquery name="get_assignees">
    <querytext>	
	select	
	        party_id,
	        role_id
        from
        	pm_project_assignment a
	where
        	project_id = :project_item_id
    </querytext>
</fullquery>

<fullquery name="get_dimensions_list">
    <querytext>	
	select 
		dimension_key, 
		title 
	from 
		rating_dimensions 
    </querytext>
</fullquery>

</queryset>