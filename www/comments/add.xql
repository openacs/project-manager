<?xml version="1.0"?>
<queryset>

<fullquery name="get_observer_role_id">
    <querytext>
	select
		role_id as observer_role_id
	from 
		pm_roles
	where	
		is_observer_p = 't'
    </querytext>
</fullquery>

</queryset>