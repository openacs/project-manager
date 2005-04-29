<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.0</version></rdbms>

  <fullquery name="pm::role::default.get_default">
    <querytext>
       SELECT role_id 
       FROM   pm_roles
       WHERE  rownum = 1
    </querytext>
  </fullquery>


  <fullquery name="pm::role::select_list_filter_helper.get_roles">
    <querytext>
        SELECT one_line || ' (' || substr(one_line,1,1) || ')' as one_line,
               role_id
        FROM pm_roles
        ORDER BY role_id
    </querytext>
  </fullquery>
</queryset>
