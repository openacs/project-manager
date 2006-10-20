<?xml version="1.0"?>
<queryset>

<fullquery name="get_projects">
    <querytext>
	select 
		item_id,
		o.package_id as object_package_id
	from
		cr_items i, acs_objects o
	where
		lower(o.title) like '%${keyword}%'
		and i.latest_revision = o.object_id
		and i.content_type = 'pm_project'
	order by
		title asc
    </querytext>
</fullquery>

<fullquery name="get_projects_by_code">
    <querytext>
	select 
		item_id,
		o.package_id as object_package_id
	from
		cr_items i, acs_objects o, pm_projects p
	where
		lower(p.project_code) like '%${keyword}%'
		and i.latest_revision = o.object_id
		and o.object_id = p.project_id
	order by
		title asc
    </querytext>
</fullquery>
</queryset>