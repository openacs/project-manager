<?xml version="1.0"?>
<queryset>

<fullquery name="get_all_projects">
    <querytext>
	select 
    		p.item_id as project_item_id, 
    		p.title,
		to_char(p.planned_end_date, 'YYYY-MM-DD') as planned_end_date
    	from 
    		pm_projectsx p,
    		cr_items i
    	where
    		p.project_id = i.live_revision
    		and p.item_id = i.item_id
     		and p.object_package_id = :package_id
    		and exists (
			select 1 from acs_object_party_privilege_map ppm
			where ppm.object_id = p.project_id
			and ppm.privilege = 'read'
			and ppm.party_id = :user_id)
    		$extra_query
	[template::list::filter_where_clauses -and -name projects]
	order by planned_end_date asc
    </querytext>
</fullquery>

<fullquery name="get_amount_total">
    <querytext>
	select 
		amount_total 
	from 
		iv_offers 
	where 
		offer_id = :offer_id
    </querytext>
</fullquery>

</queryset>
