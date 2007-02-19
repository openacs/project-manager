<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>
  
  <fullquery name="pm::project::get_project_id.get_project_id">
    <querytext>
      SELECT
      live_revision
      FROM
      cr_items
      WHERE
      item_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::get_project_item_id.get_project_item">
    <querytext>
      SELECT
      i.item_id
      FROM
      cr_items i,
      cr_revisions r
      WHERE
      i.item_id = r.item_id and
      r.revision_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::default_status_open.get_default_status_open">
    <querytext>
      select status_id 
      from pm_project_status 
      where status_type = 'o'
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::default_status_closed.get_default_status_closed">
    <querytext>
      select status_id 
      from pm_project_status 
      where status_type = 'c'
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::new.new_project_item">
    <querytext>
        select pm_project__new_project_item (
                :project_name,
                :project_code,
                :parent_id,
                :goal,
                :description,
                :mime_type,
                to_timestamp(:planned_start_date,'YYYY MM DD HH24 MI SS'),
                to_timestamp(:planned_end_date,'YYYY MM DD HH24 MI SS'),
                null,
                null,
                :ongoing_p,
                :status_id,
                :organization_id,
		:dform,
                current_timestamp,
                :creation_user,
                :creation_ip,
                :package_id
        );
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

  <fullquery name="pm::project::close.select_tasks">
    <querytext>
        SELECT
        task_id
        FROM
        cr_items i,
        pm_tasks_active t
        WHERE
        i.item_id   = t.task_id and
        i.parent_id = :project_item_id
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

  <fullquery name="pm::project::compute_status.tasks_query">
    <querytext>
        SELECT
        case when t.actual_hours_worked is null then 0 
                else t.actual_hours_worked end as worked,
        t.estimated_hours_work as to_work,
        t.item_id as my_iid,
        to_char(to_date(to_char(end_date,'YYYY-MM-DD HH24:MI'),'YYYY-MM-DD HH24:MI'),'J') as task_deadline_j,
        to_char(to_date(earliest_start,'YYYY-MM-DD HH24:MI'),'J') as old_earliest_start_j,
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
        select
        d.dependency_id,
        d.task_id as task_item_id,
        d.parent_task_id,
        d.dependency_type
        from
        pm_task_dependency d
        where
        d.task_id in ([join $task_list ", "])
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.project_info">
    <querytext>
        select
        to_char(planned_start_date,'J') as start_date_j,
        to_char(planned_end_date,'J') as end_date_j,
        ongoing_p
        from         
        pm_projects 
        where
        project_id = (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.update_project">
    <querytext>
        update
        pm_projects
        set 
        actual_hours_completed = :actual_hours_completed,
        estimated_hours_total  = :estimated_hours_total,
        earliest_finish_date   = :max_earliest_finish,
        latest_finish_date     = :min_latest_start
        where
        project_id = (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>


   <fullquery name="pm::project::parent_project_id.project_parent">
         <querytext>

	select i.parent_id
	from cr_items i, cr_items ip, pm_projects p, pm_projects pp
	where i.item_id = :project_id
	and ip.item_id = i.parent_id
	and p.project_id = i.latest_revision
	and pp.project_id = ip.latest_revision

         </querytext>
   </fullquery>

  <fullquery name="pm::project::compute_parent_status.get_parent_id">
    <querytext>
        select
        parent_id
        from
        cr_items
        where
        item_id = :my_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_parent_status.get_root_folder">
    <querytext>
        select pm_project__get_root_folder (:package_id, 'f')
    </querytext>
  </fullquery>

  <fullquery name="pm::project::root_folder.get_root_folder">
    <querytext>
        select pm_project__get_root_folder (:package_id, 'f')
    </querytext>
  </fullquery>


  <fullquery name="pm::project::compute_status.update_task">
    <querytext>
        update
        pm_tasks_revisions
        set 
        earliest_start  = :es,
        earliest_finish = :ef,
        latest_start    = :ls,
        latest_finish   = :lf
        where
        task_revision_id = (select live_revision from cr_items where item_id = :task_item)
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
      $extra_query
      s.status_type = 'o'
      ORDER BY
      lower(p.title), lower(o.name) 
    </querytext>
  </fullquery>

   <fullquery name="pm::project::get_status_description_not_cached.project_status">
         <querytext>

	select s.description
	from cr_items i, pm_projects p, pm_project_status s
	where i.item_id = :project_item_id
	and p.project_id = i.latest_revision
	and s.status_id = p.status_id

         </querytext>
   </fullquery>

  <fullquery name="pm::project::assigned_p.assigned_p">
    <querytext>
      SELECT
      party_id
      FROM
      pm_project_assignment
      WHERE
      project_id = :project_item_id and
      party_id = :party_id
      LIMIT 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assignee_role_list.get_assignees_roles">
    <querytext>
        SELECT
        party_id,
        role_id
        FROM 
        pm_project_assignment a
        WHERE
	project_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status_mins.select_project_children">
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

  <fullquery name="pm::project::compute_status_mins.tasks_group_query">
    <querytext>
        select
        sum(t.actual_hours_worked) as actual_hours_completed,
        sum(t.estimated_hours_work) as estimated_hours_total,
        to_char(current_timestamp,'YYYY-MM-DD HH24:MI') as today
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

  <fullquery name="pm::project::compute_status_mins.tasks_query">
    <querytext>
        SELECT
        case when t.actual_hours_worked is null then 0 
                else t.actual_hours_worked end as worked,
        t.estimated_hours_work as to_work,
        t.item_id as my_iid,
        to_char(end_date,'YYYY-MM-DD HH24:MI') as task_deadline,
        to_char(earliest_start,'YYYY-MM-DD HH24:MI') as old_earliest_start,
        to_char(earliest_finish,'YYYY-MM-DD HH24::MI') as old_earliest_finish,
        to_char(latest_start,'YYYY-MM-DD HH24::MI') as old_latest_start,
        to_char(latest_finish,'YYYY-MM-DD HH24::MI') as old_latest_finish,
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

  <fullquery name="pm::project::compute_status_mins.dependency_query">
    <querytext>
        select
        d.dependency_id,
        d.task_id as task_item_id,
        d.parent_task_id,
        d.dependency_type
        from
        pm_task_dependency d
        where
        d.task_id in ([join $task_list ", "])
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status_mins.project_info">
    <querytext>
        select
        to_char(planned_start_date,'YYYY-MM-DD HH24:MI') as start_date,
        to_char(planned_end_date,'YYYY-MM-DD HH24:MI') as end_date,
        ongoing_p
        from         
        pm_projects 
        where
        project_id = (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status_mins.update_project">
    <querytext>
        update
        pm_projects
        set 
        actual_hours_completed = :actual_hours_completed,
        estimated_hours_total  = :estimated_hours_total,
        earliest_finish_date   = :max_earliest_finish,
        latest_finish_date     = :min_latest_start
        where
        project_id = (select live_revision from cr_items where item_id = :project_item_id)
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_parent_status.get_parent_id">
    <querytext>
        select
        parent_id
        from
        cr_items
        where
        item_id = :my_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_parent_status.get_root_folder">
    <querytext>
        select pm_project__get_root_folder (:package_id, 'f')
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status_mins.update_task">
    <querytext>
        update
        pm_tasks_revisions
        set 
        earliest_start  = :es,
        earliest_finish = :ef,
        latest_start    = :ls,
        latest_finish   = :lf
        where
        task_revision_id = (select live_revision from cr_items where item_id = :task_item)
    </querytext>
  </fullquery>

   <fullquery name="pm::project::subprojects.subprojects">
         <querytext>

	    select i.item_id as project_item_id
	    from cr_items i, pm_projects p
	    where p.project_id = i.latest_revision
	    and i.parent_id in ([join $project_list ,])

         </querytext>
   </fullquery>

<fullquery name="pm::project::get_all_subprojects_not_cached.get_subprojects">
    <querytext>
	select 
	    	c.item_id 
	from 
		cr_items c
	where 
	    	c.parent_id = :parent
		and c.content_type = 'pm_project'
    </querytext>
</fullquery>

<fullquery name="pm::project::check_projects_status.get_projects_status">
    <querytext>
	select
		distinct
		status_id
	from
		pm_projectsx
	where
		item_id in ($projects)
    </querytext>
</fullquery>

</queryset>
