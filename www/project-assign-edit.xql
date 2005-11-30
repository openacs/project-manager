<?xml version="1.0"?>
<queryset>

  <fullquery name="assignee_query">
    <querytext>
      SELECT
      a.party_id,
      r.role_id
      FROM
      pm_project_assignment a,
      pm_roles r,
      persons p          
      WHERE
      a.role_id = r.role_id and
      a.party_id = p.person_id and
      a.project_id = :project_item_id
      ORDER BY
      r.role_id,    p.first_names,
      p.last_name
    </querytext>
  </fullquery>
  
  <fullquery name="get_assignees">
    <querytext>
      select distinct
      p.first_names || ' ' || p.last_name as name,
      p.person_id
      FROM
      persons p,
      acs_rels r,
      membership_rels mr
      WHERE
      r.object_id_one = :user_group_id and
      mr.rel_id = r.rel_id and
      p.person_id = r.object_id_two and
      member_state = 'approved'
      ORDER BY name
    </querytext>
  </fullquery>

</queryset>
