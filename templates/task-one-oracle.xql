<?xml version="1.0"?>
<queryset>
  <rdbms><type>oracle</type><version>8.0</version></rdbms>
  <fullquery name="task_query">
    <querytext>
	SELECT t.item_id,
               t.parent_id as project_item_id,
               t.title as task_title,
               t.revision_id,
               t.description,
               t.mime_type,
	       to_char(t.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
	       to_char(t.earliest_start,'J') as earliest_start_j,
	       to_char(t.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
	       to_char(t.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
	       to_char(t.latest_start,'J') as latest_start_j,
	       to_char(t.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
	       to_char(t.end_date,'YYYY-MM-DD HH24:MI:SS') as end_date,
	       to_char(current_date,'J') as today_j,
               t.estimated_hours_work,
               t.estimated_hours_work_min,
               t.estimated_hours_work_max,
               t.percent_complete,
               t.priority,
               t.dform,
               i.live_revision,
	       p.first_names || ' ' || p.last_name as creation_user,
               proj_rev.title as project_name
	FROM   pm_tasks_revisionsx t, 
               cr_items i,
               persons p,
               cr_items proj,
               cr_revisions proj_rev
	WHERE  t.item_id = :task_id and
               t.revision_id = :task_revision_id and
               t.item_id = i.item_id and
               t.creation_user = p.person_id and
               t.parent_id = proj.item_id and
               proj.live_revision = proj_rev.revision_id
    </querytext>
  </fullquery>

  <fullquery name="dependency_query">
    <querytext>
	SELECT
        t.title as task_title,
	to_char(t.end_date,'MM/DD/YYYY') as end_date,
        t.percent_complete,
        i.live_revision,
        d.parent_task_id,
        d.dependency_type
	FROM
	pm_tasks_revisionsx t, cr_items i, pm_task_dependency d
	WHERE
        d.task_id        = :task_id and
        d.parent_task_id = t.item_id and 
        t.revision_id    = i.live_revision and
        t.item_id        = i.item_id
        [template::list::orderby_clause -name dependency -orderby]
    </querytext>
  </fullquery>

  <fullquery name="dependency2_query">
    <querytext>
	SELECT t.title as task_title,
	       to_char(t.end_date,'MM/DD/YYYY') as end_date,
               t.percent_complete,
               i.live_revision,
               d.parent_task_id,
               d.dependency_type,
               d.task_id as d_task_id
	FROM   pm_tasks_revisionsx t, 
               cr_items i, 
               pm_task_dependency d
	WHERE  d.task_id        = t.item_id and
               d.parent_task_id = :task_id and 
               t.revision_id    = i.live_revision and
               t.item_id        = i.item_id
               [template::list::orderby_clause -name dependency2 -orderby]
    </querytext>
  </fullquery>

  <fullquery name="task_people_query">
    <querytext>
        select r.one_line,
               u.first_names || ' ' || u.last_name as user_info,
               r.role_id
        from   pm_task_assignment a,
               persons u,
               pm_roles r
        where  a.task_id  = :task_id and
               u.person_id = a.party_id and
               a.role_id  = r.role_id
        [template::list::orderby_clause -name people -orderby]
    </querytext>
  </fullquery>

  <fullquery name="xrefs_query">
    <querytext>
      SELECT x.task_id_1 as x_task_id,
             r.title,
	     to_char(r.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
	     r.earliest_start - current_date as days_to_earliest_start,
	     to_char(r.earliest_start,'J') as earliest_start_j,
	     to_char(r.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
	     r.earliest_finish - current_date as days_to_earliest_finish,
	     to_char(r.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
	     r.latest_start - current_date as days_to_latest_start,
	     to_char(r.latest_start,'J') as latest_start_j,
	     to_char(current_date,'J') as today_j,
	     to_char(r.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
	     r.latest_finish - current_date as days_to_latest_finish
      FROM   pm_task_xref x, pm_tasks_revisionsx r, cr_items i
      WHERE  x.task_id_2      = :task_id and
             x.task_id_1      = r.item_id and
             r.revision_id    = i.live_revision
      UNION
      SELECT x2.task_id_2 as x_task_id,
             r2.title,
	     to_char(r2.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
	     r2.earliest_start - current_date as days_to_earliest_start,
	     to_char(r2.earliest_start,'J') as earliest_start_j,
	     to_char(r2.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
	     r2.earliest_finish - current_date as days_to_earliest_finish,
	     to_char(r2.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
	     r2.latest_start - current_date as days_to_latest_start,
	     to_char(r2.latest_start,'J') as latest_start_j,
	     to_char(current_date,'J') as today_j,
	     to_char(r2.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
	     r2.latest_finish - current_date as days_to_latest_finish
      FROM   pm_task_xref x2, pm_tasks_revisionsx r2, cr_items i2
      WHERE  x2.task_id_1      = :task_id and
             x2.task_id_2      = r2.item_id and
             i2.live_revision  = r2.revision_id
    </querytext>
  </fullquery>

</queryset>
