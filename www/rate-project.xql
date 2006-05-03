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
	        distinct(party_id),
	        role_id
        from
        	pm_project_assignment a, group_member_map g
	where
        	project_id = :project_item_id
		and g.group_id = :filter_group_id
		and g.member_id = party_id
		and party_id is not null
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