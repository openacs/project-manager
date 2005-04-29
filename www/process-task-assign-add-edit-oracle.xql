<?xml version="1.0"?>
<queryset>
  <fullquery name="get_tasks">
    <querytext>
      SELECT  one_line,
              description,
              process_task_id
      FROM    pm_process_task 
      WHERE   process_task_id in ([join $process_task_id ","])
      ORDER BY process_task_id
    </querytext>
  </fullquery>

  <fullquery name="get_users">
    <querytext>
      SELECT  p.first_names || ' ' || p.last_name as who,
              p.person_id
      FROM    persons p,
              acs_rels r,
              membership_rels mr
      WHERE   r.object_id_one = :user_group_id and
              mr.rel_id = r.rel_id and
              p.person_id = r.object_id_two and
              member_state = 'approved'
      ORDER BY p.first_names, 
               p.last_name
    </querytext>
  </fullquery>

  <fullquery name="get_roles">
    <querytext>
      SELECT one_line,
             role_id
      FROM   pm_roles
      ORDER BY sort_order
    </querytext>
  </fullquery>

  <fullquery name="delete_assignments">
    <querytext>
      DELETE from pm_process_task_assignment
      WHERE process_task_id in ([join $process_task_id ","])
    </querytext>
  </fullquery>

  <fullquery name="add_assignment">
    <querytext>
      INSERT into pm_process_task_assignment
      (process_task_id,
       role_id,
       party_id) 
      VALUES
      (:t_id,
       :r_id,
       :p_id)
    </querytext>
  </fullquery>

  <fullquery name="get_current_users">
    <querytext>
      SELECT party_id
      FROM   pm_process_task_assignment
      WHERE  process_task_id = :tiid
    </querytext>
  </fullquery>

  <fullquery name="get_current_roles">
    <querytext>
      SELECT role_id
      FROM   pm_process_task_assignment a
      WHERE  process_task_id = :tiid
    </querytext>
  </fullquery>

</queryset>
