<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="project_folders">
    <querytext>
        SELECT
        p.item_id as project_item_id,
        p.project_id,
	p.status_id,
	s.description as pretty_status,
        p.parent_id as folder_id,
        p.object_type as content_type,
        p.title as project_name,
        p.project_code,
        to_char(p.planned_start_date, 'YYYY-MM-DD HH24:MI:SS') as planned_start_date,
        to_char(p.planned_end_date, 'YYYY-MM-DD HH24:MI:SS') as planned_end_date,
        p.ongoing_p,
        c.category_id,
        c.category_name,
        p.earliest_finish_date - current_date as days_to_earliest_finish,
        p.latest_finish_date - current_date as days_to_latest_finish,
        p.actual_hours_completed,
        p.estimated_hours_total,
        to_char(p.estimated_finish_date, 'YYYY-MM-DD HH24:MI:SS') as estimated_finish_date,
        to_char(p.earliest_finish_date, 'YYYY-MM-DD HH24:MI:SS') as earliest_finish_date,
        to_char(p.latest_finish_date, 'YYYY-MM-DD HH24:MI:SS') as latest_finish_date,
        case when o.name is null then '--no customer--' else o.name
                end as customer_name,
        o.organization_id as customer_id,
	p.object_package_id as package_id,
	to_char(p.creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date,
	to_char(p.planned_start_date, 'YYYY-MM-DD HH24:MI:SS') as start_date
        FROM pm_project_status s, pm_projectsx p 
             LEFT JOIN organizations o ON p.customer_id =
                o.organization_id 
             LEFT JOIN (
                        select 
                        om.category_id, 
                        om.object_id, 
                        t.name as category_name 
                        from 
                        category_object_map om, 
                        category_translations t, 
                        categories ctg 
                        where 
                        om.category_id = t.category_id and 
                        ctg.category_id = t.category_id and 
                        ctg.deprecated_p = 'f')
                 c ON p.item_id = c.object_id  $subprojects_from_clause $pa_from_clause
        WHERE exists (select 1 from acs_object_party_privilege_map ppm 
                    where ppm.object_id = p.project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
	and s.status_id = p.status_id
        [template::list::filter_where_clauses -and -name projects]
	[template::list::page_where_clause -and -name "projects" -key "p.project_id"]
        [template::list::orderby_clause -orderby -name projects]
    </querytext>
</fullquery>

  <fullquery name="projects_pagination">
    <querytext>
        SELECT
        p.project_id
        FROM pm_projectsx p $category_join_clause
        ,cr_items i $subprojects_from_clause $pa_from_clause
        WHERE 
        p.project_id = i.live_revision
	$current_package_where_clause
        and exists (select 1 from acs_object_party_privilege_map ppm 
                    where ppm.object_id = p.project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::filter_where_clauses -and -name projects]
        [template::list::orderby_clause -orderby -name projects]
    </querytext>
</fullquery>

</queryset>
