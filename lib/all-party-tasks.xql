<?xml version="1.0"?>
<queryset>


<fullquery name="tasks">
    <querytext>
	SELECT
        t.item_id as task_item_id,
        t.parent_id as project_item_id,
        t.title,
	to_char(t.end_date,'YYYY-MM-DD HH24:MI:SS') as end_date,
	to_char(t.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
	t.earliest_start - current_date as days_to_earliest_start,
	to_char(t.earliest_start,'J') as earliest_start_j,
	to_char(t.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
	t.earliest_finish - current_date as days_to_earliest_finish,
	to_char(t.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
	t.latest_start - current_date as days_to_latest_start,
	to_char(t.latest_start,'J') as latest_start_j,
	to_char(current_date,'J') as today_j,
	to_char(t.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
	t.latest_finish - current_date as days_to_latest_finish,
	to_char(t.end_date,'YYYY-MM-DD HH24:MI:SS') as end_date,
	t.end_date - current_date as days_to_end_date,
        t.percent_complete,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        t.actual_hours_worked,
        s.status_type,
        s.description as status_description,
        r.is_lead_p,
	r.is_observer_p,
	t.priority,
	t.party_id,
	t.parent_id,
	d.parent_task_id,
	o.title as project_name
	FROM
	(select tr.item_id,
                ta.party_id,
                ta.role_id,
                tr.title,
                tr.end_date,
                tr.earliest_start,
                tr.earliest_finish,
                tr.latest_start,
                tr.latest_finish,
                tr.percent_complete,
                tr.estimated_hours_work,
                tr.estimated_hours_work_min,
                tr.estimated_hours_work_max,
                tr.actual_hours_worked,
                tr.parent_id,
                tr.revision_id,
		tr.description,
		tr.priority
	   from cr_items ci,
	  pm_tasks_revisionsx tr
          LEFT JOIN
          pm_task_assignment ta ON tr.item_id = ta.task_id
	  -- get only live revisions
	  where ci.live_revision = tr.revision_id
	  [template::list::page_where_clause -and -name "tasks" -key "tr.item_id"]) t
            LEFT JOIN
            pm_roles r
            ON t.role_id = r.role_id
	    LEFT JOIN	
	    pm_task_dependency d
	    ON t.item_id = d.task_id,
        pm_tasks_active ti,
        pm_task_status s,
	cr_items cp,
	acs_objects o
	WHERE
        t.parent_id   = cp.item_id 
	and t.item_id = ti.task_id 
	and ti.status = s.status_id
	and ti.status = '1'
	and cp.live_revision = o.object_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                  where ppm.object_id = ti.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
	and t.party_id = :from_party_id
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
</fullquery>

<fullquery name="tasks_pagination">
    <querytext>
	SELECT        
		t.item_id as task_item_id
	FROM
	(select tr.item_id,
                ta.party_id,
                ta.role_id,
                tr.title,
                tr.end_date,
                tr.earliest_start,
                tr.earliest_finish,
                tr.latest_start,
                tr.latest_finish,
                tr.percent_complete,
                tr.estimated_hours_work,
                tr.estimated_hours_work_min,
                tr.estimated_hours_work_max,
                tr.actual_hours_worked,
                tr.parent_id,
                tr.revision_id,
		tr.description,
		tr.priority
	   from cr_items ci, pm_tasks_revisionsx tr
          LEFT JOIN
          pm_task_assignment ta ON tr.item_id = ta.task_id,  pm_roles r
	  -- get only live revisions
	  where ci.live_revision = tr.revision_id
          and ta.role_id = r.role_id
          and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = tr.item_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
	) t,
        pm_tasks_active ti,
        pm_task_status s,
	cr_items cp,
	acs_objects o
	WHERE
        t.parent_id    = cp.item_id
        and t.item_id  = ti.task_id
        and ti.status  = s.status_id
	and ti.status  = '1'
	and t.party_id = :from_party_id
	and cp.live_revision = o.object_id
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
</fullquery>

</queryset>