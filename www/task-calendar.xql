<?xml version="1.0"?>
<queryset>
  
  <fullquery name="roles_and_abbrevs">
    <querytext>
    SELECT one_line as role,
           substr(one_line,1,1) as abbreviation
    FROM   pm_roles
    </querytext>
  </fullquery>

  <fullquery name="users_list">
    <querytext>
      select
        p.first_names || ' ' || p.last_name as name,
        p.person_id as party_id
        FROM
        persons p,
        acs_rels r,
        membership_rels mr
        WHERE
        r.object_id_one = :user_group_id and
        mr.rel_id = r.rel_id and
        p.person_id = r.object_id_two and
        member_state = 'approved'
        ORDER BY
        p.first_names, p.last_name
    </querytext>
  </fullquery>

</queryset>
