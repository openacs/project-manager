<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.0</version></rdbms>

  <fullquery name="pm::task::get_item_id.get_item_id">
    <querytext>
      SELECT i.item_id
      FROM   cr_items i,
             cr_revisions r
      WHERE  i.item_id = r.item_id and
             r.revision_id = :task_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::get_revision_id.get_revision_id">
    <querytext>
      SELECT live_revision
      FROM   cr_items i
      WHERE  i.item_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::current_status.get_current_status">
    <querytext>
      select status
      from pm_tasks
      where task_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::open_p.open_p">
    <querytext>
      SELECT case when status_type = 'c' 
                  then 0 
                  else 1 end as open_p
      FROM   pm_tasks t,
             pm_task_status s
      WHERE  task_id  = :task_item_id and
             t.status = s.status_id
    </querytext>
  </fullquery>

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

  <fullquery name="pm::task::options_list.get_dependency_tasks">
    <querytext>
      SELECT r.item_id, 
             r.title as task_title        
      FROM   pm_tasks_revisionsx r, 
             cr_items i,
             pm_tasks t,
             pm_task_status s
      WHERE r.parent_id = :project_item_id and
            r.revision_id = i.live_revision and
            i.item_id = t.task_id and
            t.status  = s.status_id and
            s.status_type = 'o'
      $union_clause
     ORDER BY task_title
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
                   p_creation_date            => sysdate ,
                   p_creation_user            => :update_user,
                   p_creation_ip              => :update_ip,
                   p_package_id               => :package_id);
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
                      p_creation_date            => :creation_date,
                      p_creation_user            => :creation_user,
                      p_creation_ip              => :creation_ip,
                      p_package_id               => :package_id);
         end;
    </querytext>
  </fullquery>

</queryset>
