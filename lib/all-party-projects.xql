<?xml version="1.0"?>
<queryset>

<fullquery name="projects">
    <querytext>
        select 
		* 
	from (
		select 
			distinct
        		p.item_id as project_item_id,
        		p.project_id,
			p.status_id,
        		p.parent_id as folder_id,
        		p.object_type as content_type,
        		p.title as project_name,
        		p.project_code,
        		to_char(p.planned_end_date, 'YYYY-MM-DD HH24:MI:SS') as planned_end_date,
        		p.ongoing_p,
        		p.customer_id as customer_id, f.package_id
        	from 
			pm_projectsx p, 
        		cr_items i, 
			cr_folders f,
			pm_project_assignment a
        	where 
        		p.project_id = i.live_revision 
			and i.parent_id = f.folder_id
			and a.project_id = p.item_id
			and a.party_id = :from_party_id
		) proj
        where 
		exists (
			select 1 
			from acs_object_party_privilege_map ppm 
               		where ppm.object_id = proj.project_id
               		and ppm.privilege = 'read'
               		and ppm.party_id = :user_id
			)
		and proj.status_id = '1'
        	[template::list::filter_where_clauses -and -name projects]
	        [template::list::orderby_clause -name projects -orderby]
    </querytext>
</fullquery>

</queryset>
