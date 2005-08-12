<?xml version="1.0"?>
<queryset>

<fullquery name="get_projects">
   <querytext>
	select 
		distinct
    		i.item_id, 
    		p.object_id, 
    		p.object_title 
	from 
    		pm_projectsx p, 
    		cr_items i,
    		acs_objects o
	where 
    		p.object_id = i.live_revision 
    		and i.item_id <> :project_item_id
    		and p.object_id = o.object_id
    		and o.package_id = :package_id
   </querytext>
</fullquery>

<fullquery name="get_search_projects">
   <querytext>
	select 
		distinct
		i.item_id, 
		p.object_id, 
		p.object_title 
	from 
		pm_projectsx p, 
		cr_items i,
		acs_objects o
	where 
		p.object_id = i.live_revision 
		and p.object_id = o.object_id
		and o.package_id <> :package_id
		and p.title like '%'||:search_key||'%'
   </querytext>
</fullquery>

</queryset>