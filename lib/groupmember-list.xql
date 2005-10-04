<?xml version="1.0"?>
<queryset>

<fullquery name="get_party_name">
    <querytext>
	select
		party_name
	from
		party_names
	where 
		party_id = :party_id
    </querytext>
</fullquery>

<fullquery name="get_customers">
    <querytext>
	select
		distinct customer_id
	from
		pm_projectsx 
	where 
		object_package_id = :package_id
    </querytext>
</fullquery>

<fullquery name="get_members">
    <querytext>
	select
		distinct
		pa.*,
		pn.party_name as name,
		p.email as email,
		to_char(proj.planned_end_date, 'YYYY-MM-DD') as deadline,
		proj.customer_id
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
		and proj.object_package_id = :package_id
		[template::list::filter_where_clauses -and -name members]
		[template::list::orderby_clause -orderby -name members]
    </querytext>
</fullquery>

</queryset>