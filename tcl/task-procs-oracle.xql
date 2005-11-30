<?xml version="1.0"?>

<queryset>

<rdbms><type>oracle</type><version>9.2</version></rdbms>

  <fullquery name="pm::task::default_status_open.get_default_status_open">
    <querytext>
      select status_id 
      from pm_task_status 
      where status_type = 'o' and 
            rownum = 1
    </querytext>
  </fullquery>

  <fullquery name="pm::task::default_status_closed.get_default_status_closed">
    <querytext>
      select status_id 
      from pm_task_status 
      where status_type = 'c' and 
            rownum = 1
    </querytext>
  </fullquery>

  <fullquery name="pm::task::edit.new_task_revision">
    <querytext>
      begin
         :1 := pm_task.new_task_revision (
                   p_task_id                  => :task_item_id,
                   p_project_id               => :project_item_id,
                   p_title                    => :title,
                   p_description              => :description,
                   p_mime_type                => :mime_type,
                   p_end_date                 => [pm::util::datenvl -value $end_date -value_if_null "null" -value_if_not_null "to_timestamp('$end_date','YYYY MM DD HH24 MI SS')"],
                   p_percent_complete         => :percent_complete,
                   p_estimated_hours_work     => :estimated_hours_work,
                   p_estimated_hours_work_min => :estimated_hours_work_min,
                   p_estimated_hours_work_max => :estimated_hours_work_max,
                   p_actual_hours_worked      => :actual_hours_worked,
                   p_status_id                => :status_id,
                   p_creation_date            => current_timestamp ,
                   p_creation_user            => :update_user,
                   p_creation_ip              => :update_ip,
                   p_package_id               => :package_id,
                   p_priority                 => :priority);
       end;
    </querytext>
  </fullquery>

  <fullquery name="pm::task::new.new_task_item">
    <querytext>
        begin 
            :1 := pm_task.new_task_item (
                      p_project_id               => :project_id,
                      p_title                    => :title,
                      p_description              => :description,
                      p_mime_type                => :mime_type,
                      p_end_date                 => [pm::util::datenvl -value $end_date -value_if_null "null" -value_if_not_null "to_timestamp('$end_date','YYYY MM DD HH24 MI SS')"],
                      p_percent_complete         => :percent_complete,
                      p_estimated_hours_work     => :estimated_hours_work,
                      p_estimated_hours_work_min => :estimated_hours_work_min,
                      p_estimated_hours_work_max => :estimated_hours_work_max,
                      p_status_id                => :status_id,
                      p_process_instance_id      => :process_instance_id,
                      p_creation_date            => :creation_date,
                      p_creation_user            => :creation_user,
                      p_creation_ip              => :creation_ip,
                      p_package_id               => :package_id,
                      p_priority                 => :priority);
         end;
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
      party_id = :party_id and
      rownum = 1
    </querytext>
  </fullquery>

</queryset>
