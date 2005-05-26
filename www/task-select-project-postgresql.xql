<?xml version="1.0"?>
<queryset>

  <fullquery name="select_a_project">
    <querytext>
        SELECT
        p.item_id as project_item_id,
        p.title as project_name,
        p.description as description,
        p.mime_type,
        o.organization_id as customer_id,
        o.name as customer_name
        FROM 
        pm_projectsx p
          LEFT JOIN
          organizations o
          ON
          p.customer_id = o.organization_id, 
        cr_items i, 
        pm_project_status s
        WHERE p.project_id = i.live_revision and
        p.parent_id = :root_folder and
        p.status_id = s.status_id 
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = p.project_id
                    and ppm.privilege = 'create'
                    and ppm.party_id = :user_id)
        [template::list::filter_where_clauses -and -name projects]
        [template::list::orderby_clause -orderby -name projects]
    </querytext>
  </fullquery>

</queryset>
