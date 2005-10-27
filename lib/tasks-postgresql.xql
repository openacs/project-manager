<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="tasks">
    <querytext>
	SELECT        t.item_id as task_item_id,
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
        t.is_lead_p,
	t.is_observer_p,
	t.priority,
	t.party_id,
	t.parent_id,
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
		pr.is_observer_p,
		tr.description,
		tr.priority,
		pr.is_lead_p
	   from pm_tasks_revisionsx tr, pm_task_assignment ta, cr_items ci, pm_roles pr,
	-- Select only tasks where you are participating in a certain role.
                (select distinct task_id from pm_task_assignment where party_id = :user_id) my_tasks
           where ta.task_id = tr.item_id
        -- We need to join again with the role, as we are supposed to get all the participants
        -- This is not good... We should probably get them in the TCL view..
           and ta.role_id = pr.role_id
           and ci.live_revision = tr.revision_id and
           tr.item_id = my_tasks.task_id
 	   $done_clause) t,
        pm_tasks_active ti,
        pm_task_status s,
	cr_items cp,
	acs_objects o
	WHERE
        t.parent_id     = cp.item_id and
        t.item_id       = ti.task_id and
        ti.status       = s.status_id
	and cp.live_revision = o.object_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = ti.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
</fullquery>


<fullquery name="tasks_pagination">
    <querytext>
	SELECT        t.item_id as task_item_id,
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
        t.is_lead_p,
	t.is_observer_p,
	t.priority,
	t.party_id,
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
		pr.is_observer_p,
		tr.description,
		tr.priority,
		pr.is_lead_p
	   from pm_tasks_revisionsx tr, pm_task_assignment ta, cr_items ci, pm_roles pr,
	-- Select only tasks where you are participating in a certain role.
                (select distinct task_id from pm_task_assignment where party_id = :user_id) my_tasks
           where ta.task_id = tr.item_id
        -- We need to join again with the role, as we are supposed to get all the participants
        -- This is not good... We should probably get them in the TCL view..
           and ta.role_id = pr.role_id
           and ci.live_revision = tr.revision_id and
           tr.item_id = my_tasks.task_id
 	   $done_clause) t,
        pm_tasks_active ti,
        pm_task_status s,
	cr_items cp,
	acs_objects o
	WHERE
        t.parent_id     = cp.item_id and
        t.item_id       = ti.task_id and
        ti.status       = s.status_id
	and cp.live_revision = o.object_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = ti.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
</fullquery>

<fullquery name="get_assignee_name">
    <querytext>
	select 
		username 
	from 
		users 
	where 
		user_id = :party_id
    </querytext>
</fullquery>

<fullquery name="get_logger_project">
    <querytext>
	select 
		rel.object_id_two 
	from 
		acs_rels rel, 
		acs_objects o 
	where
		rel_type  ='application_data_link' 
		and object_id_two = o.object_id 
		and o.object_type = 'logger_project'
		and rel.object_id_one = :parent_id
    </querytext>
</fullquery>

</queryset>
