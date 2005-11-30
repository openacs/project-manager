<?xml version="1.0"?>

<!-- @author  (jader-ibr@bread.com) -->
<!-- @creation-date 2004-11-18 -->
<!-- @arch-tag: 9e1e983e-49f7-476e-ace6-4879f552bc76 -->
<!-- @cvs-id $Id$ -->

<queryset>

  <fullquery name="pm::task::assign_remove_everyone.remove_assignment">
    <querytext>
      DELETE FROM 
      pm_task_assignment 
      WHERE 
      task_id  = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::unassign.remove_assignment">
    <querytext>
      DELETE FROM 
      pm_task_assignment 
      WHERE 
      task_id  = :task_item_id and
      party_id = :party_id
    </querytext>
  </fullquery>

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

  <fullquery name="pm::task::edit.update_logger_entries">
    <querytext>
      UPDATE 
      logger_entries 
      SET 
      project_id = :logger_project 
      WHERE 
      entry_id in 
      (select 
      logger_entry 
      from 
      pm_task_logger_proj_map 
      where 
      task_item_id = :task_item_id)
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
      r.is_lead_p
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

  <fullquery name="pm::task::delete.mark_delete">
    <querytext>
      update pm_tasks set deleted_p = 't' where task_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::project_item_id.get_project_id">
    <querytext>
      select parent_id from cr_items where item_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::update_hours.total_hours">
    <querytext>
      SELECT sum(le.value) 
      FROM logger_entries le 
      WHERE entry_id in 
        (select logger_entry 
         from pm_task_logger_proj_map 
         where task_item_id = :task_item_id) 
      AND le.variable_id = '[logger::variable::get_default_variable_id]'
    </querytext>
  </fullquery>

  <fullquery name="pm::task::update_hours.update_current_task">
    <querytext>
      UPDATE                    
      pm_tasks_revisions
      SET
      actual_hours_worked = :total_logged_hours
      WHERE
      task_revision_id = :task_revision_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::link.link_tasks1">
    <querytext>
        INSERT INTO 
        pm_task_xref
        (task_id_1, task_id_2)
        VALUES
        (:task_item_id_1, :task_item_id_2)
    </querytext>
  </fullquery>

  <fullquery name="pm::task::link.link_tasks2">
    <querytext>
        INSERT INTO 
        pm_task_xref
        (task_id_1, task_id_2)
        VALUES
        (:task_item_id_2, :task_item_id_1)
    </querytext>
  </fullquery>

  <fullquery name="pm::task::assign.delete_assignment">
    <querytext>
       delete from
       pm_task_assignment
       where
       task_id  = :task_item_id and
       party_id = :party_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::assign.add_assignment">
    <querytext>
       insert into pm_task_assignment
       (task_id,
        role_id,
        party_id)
       values
       (:task_item_id,
        :role_id,
        :party_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::task::email_status.get_email">
    <querytext>
      select email from parties where party_id = :party
    </querytext>
  </fullquery>

  <fullquery name="pm::task::update_percent.update_percent">
    <querytext>
        UPDATE
        pm_tasks_revisions
        SET
        percent_complete = :percent_complete
        WHERE
        task_revision_id = (select 
                            live_revision
                            from
                            cr_items
                            where
                            item_id = :task_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::task::assignee_email_list.get_addresses">
    <querytext>
        SELECT
        p.email
        FROM
        parties p,
        pm_task_assignment a
        WHERE
        a.task_id = :task_item_id and
        a.party_id = p.party_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::assignee_filter_select_helper.get_people">
    <querytext>
      SELECT
      distinct(first_names || ' ' || last_name) as fullname,
      u.person_id
      FROM
      persons u,
      pm_task_assignment a,
      pm_tasks_active ts
      WHERE
      u.person_id = a.party_id and
      ts.task_id = a.task_id and
      ts.status = :status_id
      ORDER BY
      fullname
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

  <fullquery name="pm::task::email_status.get_today">
    <querytext>
      select to_char(current_timestamp,'J') from dual
    </querytext>
  </fullquery>

  <fullquery name="pm::task::email_status.get_all_open_tasks">
    <querytext>
        SELECT
        ts.task_id,
        ts.task_id as item_id,
        ts.task_number,
        t.task_revision_id,
        t.title,
        to_char(t.earliest_start,'J') as earliest_start_j,
        to_char(current_timestamp,'J') as today_j,
        to_char(t.latest_start,'J') as latest_start_j,
        to_char(t.latest_start,'YYYY-MM-DD HH24:MI') as latest_start,
        to_char(t.latest_finish,'YYYY-MM-DD HH24:MI') as latest_finish,
        t.percent_complete,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        case when t.actual_hours_worked is null then 0
                else t.actual_hours_worked end as actual_hours_worked,
        to_char(t.earliest_start,'YYYY-MM-DD HH24:MI') as earliest_start,
        to_char(t.earliest_finish,'YYYY-MM-DD HH24:MI') as earliest_finish,
        to_char(t.latest_start,'YYYY-MM-DD HH24:MI') as latest_start,
        to_char(t.latest_finish,'YYYY-MM-DD HH24:MI') as latest_finish,
        p.first_names || ' ' || p.last_name as full_name,
        p.party_id,
        (select one_line from pm_roles r where ta.role_id = r.role_id) as role
        FROM
        pm_tasks_active ts,
        pm_tasks_revisionsx t,
        pm_task_assignment ta,
        acs_users_all p,
        cr_items i,
        pm_task_status s
        WHERE
        ts.task_id    = t.item_id and
        i.item_id     = t.item_id and
        t.task_revision_id = i.live_revision and
        ts.status     = s.status_id and
        s.status_type = 'o' and
        t.item_id     = ta.task_id and
        ta.party_id   = p.party_id
        ORDER BY
        t.latest_start asc
    </querytext>
  </fullquery>

  <fullquery name="pm::task::get_url.pm_package_id">
    <querytext>
      select package_id 
      from cr_folders cf, cr_items ci1, cr_items ci2 
      where cf.folder_id = ci1.parent_id 
      and ci1.item_id = ci2.parent_id 
      and ci2.item_id = :object_id
    </querytext>
  </fullquery>

</queryset>
