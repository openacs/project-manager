<?xml version="1.0"?>
<queryset>

<fullquery name="get_members">
    <querytext>
	select
		distinct
		pa.*,
		pn.party_name as name,
		p.email as email,
		to_char(proj.planned_end_date, 'YYYY-MM-DD') as deadline,
		proj.object_package_id
	from
		pm_project_assignment pa,
		party_names pn,
		parties p,
		pm_projectsx proj
	where 
		p.party_id = pn.party_id	
		and pa.party_id = pn.party_id
		and proj.item_id = pa.project_id
		and pa.party_id in ([template::util::tcl_to_sql_list $group_members_list])
		and proj.customer_id = :customer_id
		[template::list::page_where_clause -and -name "members"]
		[template::list::orderby_clause -orderby -name "members"]
    </querytext>
</fullquery>

<fullquery name="get_members_pagination">
    <querytext>
	select
		distinct
		pa.*,
		pn.party_name as name,
		p.email as email,
		to_char(proj.planned_end_date, 'YYYY-MM-DD') as deadline,
		proj.object_package_id
	from
		pm_project_assignment pa,
		party_names pn,
		parties p,
		pm_projectsx proj
	where 
		p.party_id = pn.party_id	
		and pa.party_id = pn.party_id
		and proj.item_id = pa.project_id
		and pa.party_id in ([template::util::tcl_to_sql_list $group_members_list])
		and proj.customer_id = :customer_id
		[template::list::orderby_clause -orderby -name members]
    </querytext>
</fullquery>

</queryset>