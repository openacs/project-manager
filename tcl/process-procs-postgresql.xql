<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-10-13 -->
<!-- @arch-tag: 70453830-d78d-4b28-994c-3f72bd9de860 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.3</version>
  </rdbms>

  <fullquery name="pm::process::delete.delete_process">
    <querytext>
      UPDATE
      pm_process
      SET
      deleted_p = 't'
      WHERE
      process_id = :process_id
    </querytext>
  </fullquery>


  
  <fullquery name="pm::process::get.get_process_tasks">
    <querytext>
        SELECT
        t.process_task_id as process_tid,
        t.one_line,
        t.description,
        t.mime_type as description_mime_type,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        d.dependency_id,
        d.parent_task_id as process_parent_task
        FROM
        pm_process_task t 
          LEFT JOIN 
          pm_process_task_dependency d 
          ON t.process_task_id = d.process_task_id
        WHERE
        t.process_id = :process_id
        $process_task_where_clause
        ORDER BY
        t.ordering,
        t.process_task_id
    </querytext>
  </fullquery>

  <fullquery name="pm::process::select_html.get_processes">
    <querytext>
      SELECT
      process_id,
      one_line as process_name
      FROM
      pm_process_active
      ORDER BY
      one_line
    </querytext>
  </fullquery>
  
  <fullquery name="pm::process::task_assignee_role_list.get_assignees_roles">
    <querytext>
      SELECT
      party_id,
      role_id
      FROM
      pm_process_task_assignment
      WHERE
      process_task_id = :process_task_id
    </querytext>
  </fullquery>

  <fullquery name="pm::process::instantiate.add_instance">
    <querytext>
      INSERT INTO
      pm_process_instance
      (instance_id, process_id, project_item_id, name)
      VALUES
      (:instance_id, :process_id, :project_item_id, :name)
    </querytext>
  </fullquery>

  <fullquery name="pm::process::instances.get_process_instance">
    <querytext>
      SELECT 
      i.instance_id, 
      i.name 
      FROM 
      pm_process_instance i
      WHERE 
      i.instance_id in 
        (SELECT 
         process_instance 
         FROM 
         pm_tasks t, 
         cr_items it 
         WHERE 
         t.task_id = it.item_id and 
         it.parent_id = :project_item_id)
      ORDER BY
      i.name,
      i.instance_id
    </querytext>
  </fullquery>
  
  <fullquery name="pm::process::email_alert.get_from_address_and_more">
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

  <fullquery name="pm::process::email_alert.get_project_info">
    <querytext>
      SELECT
      project.title as project_name
      FROM
      cr_revisions project
      WHERE
      revision_id = (select live_revision from cr_items where item_id
      = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::process::email_alert.get_task_info">
    <querytext>
      SELECT
      i.item_id as task_item_id,
      t.title as subject,
      to_char(current_timestamp,'J') as today_j,
      to_char(t.earliest_start,'J') as earliest_start_j,
      to_char(t.latest_start,'J') as latest_start_j,
      to_char(t.latest_finish,'YYYY-MM-DD') as latest_finish,
      status_type
      FROM
      pm_tasks_revisionsx t, 
      cr_items i,
      pm_tasks_active a,
      pm_task_status s
      WHERE
      t.revision_id = i.live_revision and
      t.item_id = i.item_id and
      t.item_id = a.task_id and
      a.status  = s.status_id and
      a.process_instance = :process_instance_id
      ORDER BY
      t.latest_finish,
      t.title
    </querytext>
  </fullquery>

  <fullquery name="pm::process::email_alert.get_assignees">
    <querytext>
      SELECT
      p.email as to_address,
      r.one_line as role,
      case when r.is_lead_p is null then 'f' else r.is_lead_p end as is_lead_p,
      p2.first_names || ' ' || p2.last_name as user_name,
      a.task_id as my_task_id
      FROM
      pm_task_assignment a,
      parties p,
      pm_roles r,
      persons p2
      WHERE
      a.task_id  in ([join $task_list ", "]) and
      a.party_id = p.party_id and
      a.role_id  = r.role_id and
      p.party_id = p2.person_id
    </querytext>
  </fullquery>

  <fullquery name="pm::process::name.get_name">
    <querytext>
      SELECT
      pi.name || ' (' || pi.instance_id || ')' as process_name
      FROM
      pm_process_instance pi
      WHERE
      pi.instance_id = :process_instance_id
    </querytext>
  </fullquery>

  <fullquery name="pm::process::process_name.get_name">
    <querytext>
      SELECT
      one_line 
      FROM
      pm_process
      WHERE
      process_id = :process_id
    </querytext>
  </fullquery>

</queryset>
