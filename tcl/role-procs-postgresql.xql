<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="pm::role::default.get_default">
    <querytext>
       SELECT role_id 
       FROM   pm_roles
       LIMIT  1
    </querytext>
  </fullquery>


  <fullquery name="pm::role::select_list_filter_not_cached.get_roles">
    <querytext>
        SELECT one_line || ' (' || substring(one_line from 1 for 1) || ')' as one_line,
               role_id
        FROM pm_roles
        ORDER BY role_id
    </querytext>
  </fullquery>

  <fullquery name="pm::role::project_select_list_filter_not_cached.get_roles">
    <querytext>
                SELECT
                one_line || ' (' || substring(one_line from 1 for 1) || ')' as one_line,
                role_id
                FROM
                pm_roles r
                WHERE NOT EXISTS
                    (SELECT 1
                     FROM
                     pm_project_assignment pa
                     WHERE
                     r.role_id = pa.role_id and
                     pa.project_id = :project_item_id and
                     pa.party_id = :party_id)
                ORDER BY
                role_id
    </querytext>
  </fullquery>

  <fullquery name="pm::role::task_select_list_filter_not_cached.get_roles">
    <querytext>
                SELECT
                one_line || ' (' || substring(one_line from 1 for 1) || ')' as one_line,
                role_id
                FROM
                pm_roles r
                WHERE NOT EXISTS
                    (SELECT 1
                     FROM
                     pm_task_assignment ta
                     WHERE
                     r.role_id = ta.role_id and
                     ta.task_id = :task_item_id and
                     ta.party_id = :party_id)
                ORDER BY
                role_id
    </querytext>
  </fullquery>

</queryset>
