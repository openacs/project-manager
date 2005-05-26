<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="project_folders">
    <querytext>
        SELECT
        p.item_id as project_item_id,
        p.project_id,
        p.parent_id as folder_id,
        p.object_type as content_type,
        p.title as project_name,
        p.project_code,
        to_char(p.planned_start_date, 'MM/DD/YY') as planned_start_date,
        to_char(p.planned_end_date, 'MM/DD/YY') as planned_end_date,
        p.ongoing_p,
        c.category_id,
        c.category_name,
        p.earliest_finish_date - current_date as days_to_earliest_finish,
        p.latest_finish_date - current_date as days_to_latest_finish,
        p.actual_hours_completed,
        p.estimated_hours_total,
        to_char(p.estimated_finish_date, 'MM/DD/YY') as estimated_finish_date,
        to_char(p.earliest_finish_date, 'MM/DD/YY') as earliest_finish_date,
        to_char(p.latest_finish_date, 'MM/DD/YY') as latest_finish_date,
        case when o.name is null then '--no customer--' else o.name
                end as customer_name,
        o.organization_id as customer_id
        FROM pm_projectsx p 
             LEFT JOIN pm_project_assignment pa 
                ON p.item_id = pa.project_id
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
                 c ON p.item_id = c.object_id, 
        cr_items i, 
	cr_folders f,
        pm_project_status s
        WHERE 
        p.project_id = i.live_revision and
        s.status_id           = p.status_id
	and i.parent_id = f.folder_id
        and f.package_id = :package_id 
        and exists (select 1 from acs_object_party_privilege_map ppm 
                    where ppm.object_id = p.project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::filter_where_clauses -and -name projects]
        [template::list::orderby_clause -orderby -name projects]
    </querytext>
</fullquery>

</queryset>
