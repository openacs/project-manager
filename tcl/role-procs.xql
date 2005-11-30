<?xml version="1.0"?>

<queryset>

  <fullquery name="pm::role::name_not_cached.get_one_line">
    <querytext>
      SELECT
      one_line
      FROM
      pm_roles
      WHERE
      role_id = :role_id
    </querytext>
  </fullquery>

</queryset>
