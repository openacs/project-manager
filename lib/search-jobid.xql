<?xml version="1.0"?>
<queryset>

<fullquery name="get_projects">
    <querytext>
	select 
		distinct
		item_id,
		object_title,
		object_package_id
	from
		pm_projectsx
	where
		lower(object_title) like lower(:keyword)
	order by
		object_title asc
    </querytext>
</fullquery>

</queryset>