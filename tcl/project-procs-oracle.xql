<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.0</version></rdbms>
  
   <fullquery name="pm::project::get_project_item_id.get_project_item">
    <querytext>
      SELECT i.item_id
      FROM   cr_items i,
             cr_revisions r
      WHERE  i.item_id = r.item_id and
             r.revision_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::default_status_open.get_default_status_open">
    <querytext>
      select status_id 
      from pm_project_status 
      where status_type = 'o' and 
            rownum = 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::default_status_closed.get_default_status_closed">
    <querytext>
      select status_id 
      from pm_project_status 
      where status_type = 'c' and 
            rownum = 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::new.new_project_item">
    <querytext>
        begin 
          :1 :=  pm_project.new_project_item (
                p_project_name        => :project_name,
                p_project_code        => :project_code,
                p_parent_id           => :parent_id,
                p_goal                => :goal,
                p_description         => :description,
                p_mime_type           => :mime_type,
                p_planned_start_date  => to_date(:planned_start_date,'YYYY MM DD HH24 MI SS'),
                p_planned_end_date    => to_date(:planned_end_date,'YYYY MM DD HH24 MI SS'),
                p_actual_start_date   => null,
                p_actual_end_date     => null,
                p_ongoing_p           => :ongoing_p,
                p_status_id           => :status_id,
                p_customer_id         => :organization_id,
                p_creation_user       => :creation_user,
                p_creation_ip          => :creation_ip,
                p_package_id          => :package_id
        );
       end;
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.select_project_children">
    <querytext>
        SELECT  i.item_id, 
                i.content_type 
        FROM    cr_items i,
                pm_tasks_active t
        WHERE   i.item_id   = t.task_id and
                i.parent_id = :project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.tasks_group_query">
    <querytext>
        select sum(t.actual_hours_worked) as actual_hours_completed,
               sum(t.estimated_hours_work) as estimated_hours_total,
               to_char(current_timestamp,'J') as today_j
        from   pm_tasks_revisionsx t, 
               cr_items i,
               pm_tasks_active a
        where  i.item_id = a.task_id and
               t.item_id in ([join $task_list ", "]) and
               i.live_revision = t.revision_id
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.tasks_query">
    <querytext>
        SELECT case when t.actual_hours_worked is null then 0 
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
        from pm_tasks_revisionsx t, 
             cr_items i,
             pm_tasks_active ti,
             pm_task_status s
        where t.item_id in ([join $task_list ", "]) and
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
              earliest_finish_date   = :max_earliest_finish,
              latest_finish_date     = :min_latest_start
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

  <fullquery name="pm::project::compute_parent_status.get_root_folder">
    <querytext>
        select pm_project.get_root_folder (:package_id, 'f') from dual
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_status.update_task">
    <querytext>
        UPDATE pm_tasks_revisions
        SET   earliest_start  = :es,
              earliest_finish = :ef,
              latest_start    = :ls,
              latest_finish   = :lf
        WHERE task_revision_id = (select live_revision from cr_items where item_id = :task_item)
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

<fullquery name="pm::project::get_all_subprojects.get_subprojects">
    <querytext>
	select 
		distinct 
	    	p.item_id 
	from 
		pm_projectsx p, 
	    	pm_projectsx p2 
	where 
	    	p.parent_id = p2.item_id 
	    	and p.parent_id = :parent
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
