<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="pm::task::name.get_name">
    <querytext>
      SELECT
      r.title
      FROM
      cr_items i,
      cr_revisions r
      WHERE
      i.item_id = r.item_id and
      i.item_id = :task_item_id and
      i.live_revision = r.revision_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::get_item_id.get_item_id">
    <querytext>
      SELECT
      i.item_id
      FROM
      cr_items i,
      cr_revisions r
      WHERE
      i.item_id = r.item_id and
      r.revision_id = :task_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::get_revision_id.get_revision_id">
    <querytext>
      SELECT
      live_revision
      FROM
      cr_items i
      WHERE
      i.item_id = :task_item_id
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
      SELECT
      case when status_type = 'c' then 0 else 1 end as open_p
      FROM 
      pm_tasks t,
      pm_task_status s
      WHERE
      task_id  = :task_item_id and
      t.status = s.status_id
    </querytext>
  </fullquery>

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

  <fullquery name="pm::task::dependency_delete_all.delete_deps">
    <querytext>
      DELETE FROM 
      pm_task_dependency 
      WHERE 
      task_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::dependency_add.get_tasks">
    <querytext>
      SELECT
      task.item_id as t_item_id
      FROM
      cr_items task,
      cr_items project
      WHERE 
      task.parent_id = project.item_id and
      project.item_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::dependency_add.get_dependencies">
    <querytext>
      SElECT
      d.task_id as dep_task,
      d.parent_task_id as dep_task_parent
      FROM
      pm_task_dependency d
      WHERE
      d.task_id in ([join $project_tasks ", "])
    </querytext>
  </fullquery>

  <fullquery name="pm::task::dependency_add.insert_dep">
    <querytext>
      INSERT INTO 
      pm_task_dependency 
      (dependency_id, 
      task_id, 
      parent_task_id, 
      dependency_type) 
      values 
      (:dependency_id, 
      :task_item_id, 
      :parent_id, 
      'finish_before_start')
    </querytext>
  </fullquery>

  <fullquery name="pm::task::options_list.get_dependency_tasks">
    <querytext>
      SELECT
        r.item_id, 
        r.title as task_title        
	FROM
        pm_tasks_revisionsx r, 
        cr_items i,
        pm_tasks t,
        pm_task_status s
        WHERE
        r.parent_id = :project_item_id and
        r.revision_id = i.live_revision and
        i.item_id = t.task_id and
        t.status  = s.status_id and
        s.status_type = 'o'
      $union_clause
     ORDER BY
     task_title
    </querytext>
  </fullquery>

  <fullquery name="pm::task::options_list_html.get_dependency_tasks">
    <querytext>
      SELECT
        r.item_id, 
        r.title as task_title        
	FROM
        pm_tasks_revisionsx r, 
        cr_items i,
        pm_tasks t,
        pm_task_status s
        WHERE
        r.parent_id = :project_item_id and
        r.revision_id = i.live_revision and
        i.item_id = t.task_id and
        t.status  = s.status_id and
        s.status_type = 'o'
      $union_clause
     ORDER BY
     task_title
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
      :dform,
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
        :dform,
        coalesce (:creation_date,current_timestamp),
        :creation_user,
        :creation_ip,
        :package_id,
	:priority,
        :task_id)
    </querytext>
  </fullquery>


  <fullquery name="pm::task::email_alert.get_from_address_and_more">
    <querytext>
        SELECT 
        p.email as from_address,
        p2.first_names || ' ' || p2.last_name as mod_username
        FROM 
        parties p,
        persons p2
        WHERE
        p.party_id = :user_id and
        p.party_id = p2.person_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::email_alert.get_task_info">
    <querytext>
      SELECT
      t.title as subject,
      t.description,
      t.mime_type as description_mime_type,
      to_char(t.earliest_start,'MM-DD-YYYY') as earliest_start,
      to_char(t.earliest_finish,'MM-DD-YYYY') as earliest_finish,
      to_char(t.latest_start,'MM-DD-YYYY') as latest_start,
      to_char(t.latest_finish,'MM-DD-YYYY') as latest_finish,
      t.estimated_hours_work as work,
      t.estimated_hours_work_min as work_min,
      t.estimated_hours_work_max as work_max,
      t.percent_complete,
      p.title as project_name,
      t.parent_id as project_item_id,
      t.priority,
      t.end_date,
      a.process_instance
      FROM
      pm_tasks_revisionsx t, 
      pm_tasks_active a,
      cr_items i,
      cr_items project,
      pm_projectsx p
      WHERE
      t.item_id = :task_item_id and
      t.item_id = a.task_id and
      t.revision_id = i.live_revision and
      t.item_id = i.item_id and
      t.parent_id = project.item_id and
      project.item_id = p.item_id and
      project.live_revision = p.revision_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::email_alert.get_assignees">
    <querytext>
      SELECT
      p.email as to_address,
      r.one_line as role,
      r.is_lead_p,
      p.party_id
      FROM
      pm_task_assignment a,
      parties p,
      pm_roles r
      WHERE
      task_id    = :task_item_id and
      a.party_id = p.party_id and
      a.role_id  = r.role_id
    </querytext>
  </fullquery>


  <fullquery name="pm::task::get.get_tasks">
    <querytext>
      SELECT
      t.title as one_line,
      t.description,
      t.mime_type as description_mime_type,
      t.estimated_hours_work as estimated_hours_work,
      t.estimated_hours_work_min as estimated_hours_work_min,
      t.estimated_hours_work_max as estimated_hours_work_max,
      t.percent_complete,
      to_char(t.end_date, 'DD') as end_date_day,
      to_char(t.end_date, 'MM') as end_date_month,
      to_char(t.end_date, 'YYYY') as end_date_year,
      d.parent_task_id,
      i.item_id as tid,
      t.parent_id as project,
      t.priority
      FROM
      pm_tasks_revisionsx t, 
      cr_items i
        LEFT JOIN
        pm_task_dependency d
        ON i.item_id = d.task_id
      WHERE
      t.revision_id = i.live_revision and
      t.item_id = i.item_id
      $task_where_clause
    </querytext>
  </fullquery>


  <fullquery name="pm::task::assignee_role_list.get_assignees_roles">
    <querytext>
      SELECT
      party_id,
      role_id
      FROM
      pm_task_assignment
      WHERE
      task_id = :task_item_id
    </querytext>
  </fullquery>


  <fullquery name="pm::task::assignee_role_list_ext.get_assignees">
    <querytext>
      SELECT
      party_id,
      pta.role_id,
      is_lead_p,
      is_observer_p
      FROM
      pm_task_assignment pta, pm_roles r
      WHERE
      task_id = :task_item_id
      and pta.role_id = r.role_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::open.update_status">
    <querytext>
      UPDATE
      pm_tasks
      SET
      status = :status_code
      WHERE 
      task_id = :task_item_id
    </querytext>
  </fullquery>
  
  <fullquery name="pm::task::close.update_status">
    <querytext>
      UPDATE
      pm_tasks
      SET
      status = :status_code
      WHERE 
      task_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::get_assignee_names.get_assignees">
    <querytext>
      SELECT
      p.first_names || ' ' || p.last_name
      FROM
      pm_task_assignment a,
      persons p
      WHERE
      task_id = :task_item_id and
      a.party_id = p.person_id
    </querytext>
  </fullquery>

</queryset>
