<?xml version="1.0"?>

<queryset>

  <fullquery name="pm::project::get_project_id.get_project_id">
    <querytext>
      SELECT  live_revision
      FROM    cr_items
      WHERE   item_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::get_project_item_id.get_project_item">
    <querytext>
      SELECT i.item_id
      FROM   cr_items i,
             cr_revisions r
      WHERE  i.item_id = r.item_id and
             r.revision_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::log_hours.add_task_logger_map">
    <querytext>
      INSERT INTO
      pm_task_logger_proj_map
      (task_item_id,
      logger_entry)
      VALUES
      (:task_item_id,
      :entry_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.select_project_children">
    <querytext>
        SELECT
        i.item_id,
        i.content_type
        FROM
        cr_items i,
        pm_tasks_active t
        WHERE
        i.item_id   = t.task_id and
        i.parent_id = :project_item_id
    </querytext>
  </fullquery>  
                
  <fullquery name="pm::project::compute_status.tasks_query">
    <querytext>
        SELECT
        case when t.actual_hours_worked is null then 0
                else t.actual_hours_worked end as worked,
        t.estimated_hours_work as to_work,
        t.item_id as my_iid,
        to_char(end_date,'J') as task_deadline_j,
        to_char(earliest_start,'J') as old_earliest_start_j,
        to_char(earliest_finish,'J') as old_earliest_finish_j,
        to_char(latest_start,'J') as old_latest_start_j,
        to_char(latest_finish,'J') as old_latest_finish_j,
        t.percent_complete as my_percent_complete,
        s.status_type
        from
        pm_tasks_revisionsx t,
        cr_items i,
        pm_tasks_active ti,
        pm_task_status s
        where
        t.item_id in ([join $task_list ", "]) and
        i.live_revision = t.revision_id and
        i.item_id = ti.task_id and
        ti.status = s.status_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.dependency_query">
    <querytext>
        SELECT d.dependency_id,
               d.task_id as task_item_id,
               d.parent_task_id,
               d.dependency_type
        FROM  pm_task_dependency d
        WHERE d.task_id in ([join $task_list ", "])
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.project_info">
    <querytext>
        SELECT to_char(planned_start_date,'J') as start_date_j,
               to_char(planned_end_date,'J') as end_date_j,
               ongoing_p
        FROM   pm_projects
        WHERE  project_id = (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.update_project">
    <querytext>
        UPDATE pm_projects
        SET   actual_hours_completed = :actual_hours_completed,
              estimated_hours_total  = :estimated_hours_total,
              earliest_finish_date   = to_date(:max_earliest_finish, 'J'),
              latest_finish_date     = to_date(:min_latest_start, 'J')
        WHERE  project_id = (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_parent_status.get_parent_id">
    <querytext>
        select parent_id
        from   cr_items
        where  item_id = :my_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.update_task">
    <querytext>
        UPDATE pm_tasks_revisions
        SET   earliest_start  = to_date(:es, 'J'),
              earliest_finish = to_date(:ef, 'J'),
              latest_start    = to_date(:ls, 'J'),
              latest_finish   = to_date(:lf, 'J')
        WHERE task_revision_id = (select live_revision from cr_items where item_id = :task_item)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::get_logger_project.get_logger_project">
    <querytext>
      SELECT
      logger_project
      FROM
      pm_projects
      WHERE
      project_id =
        (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::get_project.get_logger_project">
    <querytext>
      SELECT
      i.item_id
      FROM
      pm_projectsx p, cr_items i
      WHERE
      i.live_revision = p.revision_id and logger_project = :logger_project
    </querytext>
  </fullquery>

  <fullquery name="pm::project::close.update_status">
    <querytext>
      UPDATE
      pm_projects
      SET
      status_id = :closed_id
      WHERE
      project_id in (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::open_p.get_open_or_closed">
    <querytext>
      SELECT
      case when status_type = 'c' then 0 else 1 end
      FROM
      pm_projectsx p,
      cr_items i,
      pm_project_status s
      WHERE
      i.item_id = p.item_id and
      i.live_revision = p.revision_id and
      p.status_id = s.status_id and
      p.item_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assign.insert_assignment">
    <querytext>
      insert into pm_project_assignment
      (project_id, role_id, party_id)
      VALUES
      (:project_item_id, :role_id, :party_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::unassign.remove_assignment">
    <querytext>
      DELETE FROM
      pm_project_assignment
      WHERE
      project_id = :project_item_id and
      party_id   = :party_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assign_remove_everyone.get_assignees">
    <querytext>
      SELECT
      party_id
      FROM
      pm_project_assignment
      WHERE
      project_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assign_remove_everyone.remove_assignment">
    <querytext>
      DELETE FROM
      pm_project_assignment
      WHERE
      project_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assignee_filter_select_helper.get_people">
    <querytext>
      SELECT
      distinct(first_names || ' ' || last_name) as fullname,
      u.person_id
      FROM
      persons u, 
      pm_project_assignment a,
      pm_projects p,
      cr_items i 
      WHERE 
      u.person_id = a.party_id and 
      i.item_id = a.project_id and
      p.status_id = :status_id and 
      i.live_revision = p.project_id
      ORDER BY
      fullname
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assignee_email_list.get_addresses">
    <querytext>
      SELECT
      p.email
      FROM 
      parties p,
      pm_project_assignment a
      WHERE
      a.project_id = :project_item_id and
      a.party_id = p.party_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::name.get_name">
    <querytext>
      SELECT
      title
      FROM
      cr_revisions p,
      cr_items i
      WHERE
      i.live_revision = p.revision_id
      and i.item_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::get_list_of_open.get_vals">
    <querytext>
      SELECT
      case when o.name is null then p.title else p.title || ' (' || o.name || ')' end,
      p.item_id
      FROM pm_projectsx p
        LEFT JOIN
        organizations o
        ON p.customer_id = o.organization_id,
      cr_items i,
      pm_project_status s
      WHERE
      p.project_id  = i.live_revision and
      s.status_id   = p.status_id and
      s.status_type = 'o'
      ORDER BY
      lower(p.title), lower(o.name)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.tasks_group_query">
    <querytext>
        select
        sum(t.actual_hours_worked) as actual_hours_completed,
        sum(t.estimated_hours_work) as estimated_hours_total,
        to_char(current_timestamp,'J') as today_j
        from
        pm_tasks_revisionsx t,
        cr_items i,
        pm_tasks_active a
        where
        i.item_id = a.task_id and
        t.item_id in ([join $task_list ", "]) and
        i.live_revision = t.revision_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::sort_subprojects.project_folders">
    <querytext>
        SELECT            
        p.item_id as project_item_id,
        p.project_id,
        p.parent_id as folder_id,
        p.object_type as content_type,
        p.title as project_name,
        p.project_code,
        to_char(p.planned_start_date, 'MM/DD/YY') as planned_start_date,
        to_char(p.planned_end_date, 'MM/DD/YY') as planned_end_date,
        p.ongoing_p,
        c.category_id,
        c.category_name,
        p.earliest_finish_date - current_date as days_to_earliest_finish,        p.latest_finish_date - current_date as days_to_latest_finish,
        p.actual_hours_completed,
        p.estimated_hours_total,
        to_char(p.estimated_finish_date, 'MM/DD/YY') as estimated_finish_date,
        to_char(p.earliest_finish_date, 'MM/DD/YY') as earliest_finish_date,
        to_char(p.latest_finish_date, 'MM/DD/YY') as latest_finish_date,
        case when o.name is null then '--no customer--' else o.name
                end as customer_name,
        o.organization_id as customer_id
        FROM pm_projectsx p
             LEFT JOIN pm_project_assignment pa
                ON p.item_id = pa.project_id
             LEFT JOIN organizations o ON p.customer_id =
                o.organization_id
             LEFT JOIN (
                        select
                        om.category_id,
                        om.object_id,
                        t.name as category_name
                        from
                        category_object_map om,
                        category_translations t,
                        categories ctg
                        where
                        om.category_id = t.category_id and
                        ctg.category_id = t.category_id and
                        ctg.deprecated_p = 'f')
                 c ON p.item_id = c.object_id,
        cr_items i, 
        pm_project_status s
        WHERE
        p.project_id = i.live_revision and
        s.status_id           = p.status_id
        and p.parent_id = :root_folder 
        [template::list::filter_where_clauses -and -name projects]
        [template::list::orderby_clause -orderby -name projects]"
    </querytext>
  </fullquery>

  <fullquery name="pm::project::sort_subprojects.get_tasks">
    <querytext>
      SELECT tr.title as task_title
      FROM pm_tasks_revisionsx tr
      WHERE tr.parent_id = :project_item_id
    </querytext>
  </fullquery>

</queryset>
