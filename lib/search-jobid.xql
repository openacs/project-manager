<?xml version="1.0"?>
<queryset>

<fullquery name="get_project">
    <querytext>
	select 
		item_id
	from
		pm_projectsx
	where
		lower(object_title) = lower(:keyword)
    </querytext>
</fullquery>

<fullquery name="get_projects">
    <querytext>
	select 
		item_id,
		object_title
	from
		pm_projectsx
	where
		lower(object_title) like '%'||lower(:keyword)||'%'
    </querytext>
</fullquery>

</queryset>