<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="pm::task::default_status_open.get_default_status_open">
    <querytext>
      select status_id 
      from pm_task_status 
      where status_type = 'o'
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="pm::task::default_status_closed.get_default_status_closed">
    <querytext>
      select status_id 
      from pm_task_status 
      where status_type = 'c'
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="pm::task::edit.new_task_revision">
    <querytext>
      select pm_task__new_task_revision (
      :task_item_id,
      :project_item_id,
      :title,
      :description,
      :mime_type,
      [pm::util::datenvl -value $end_date -value_if_null "null" -value_if_not_null ":end_date"],
      :percent_complete,
      :estimated_hours_work,
      :estimated_hours_work_min,
      :estimated_hours_work_max,
      :actual_hours_worked,
      :status_id,
      current_timestamp,
      :update_user,
      :update_ip, 
      :package_id,
      :priority)
    </querytext>
  </fullquery>

  <fullquery name="pm::task::new.new_task_item">
    <querytext>
        select pm_task__new_task_item (
        :project_id,
        :title,
        :description,
        :mime_type,
        [pm::util::datenvl -value $end_date -value_if_null "null" -value_if_not_null "to_timestamp('$end_date','YYYY MM DD HH24 MI SS')"],
        :percent_complete,
        :estimated_hours_work,
        :estimated_hours_work_min,
        :estimated_hours_work_max,
        :status_id,
        :process_instance_id,
        coalesce (:creation_date,current_timestamp),
        :creation_user,
        :creation_ip,
        :package_id,
	:priority)
    </querytext>
  </fullquery>

  <fullquery name="pm::task::assigned_p.assigned_p">
    <querytext>
      SELECT
      party_id
      FROM
      pm_task_assignment
      WHERE
      task_id  = :task_item_id and
      party_id = :party_id
      LIMIT 1
    </querytext>
  </fullquery>

</queryset>
