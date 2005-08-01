<?xml version="1.0"?>
<queryset>

<fullquery name="update_context_id">
    <querytext>	
	update ratings 
	set context_object_id = :context_object_id 
	where rating_id = :rating_id
    </querytext>
</fullquery>

</queryset>