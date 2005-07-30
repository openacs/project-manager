<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="tasks">
    <querytext>
	SELECT distinct
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
        u.person_id,
        u.first_names,
        u.last_name,
        t.percent_complete,
        d.parent_task_id,
        d.dependency_type,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        t.actual_hours_worked,
        s.status_type,
        s.description as status_description,
        r.is_lead_p,
	t.priority,
        p.customer_id,
        p.title as project_name,
	ar.object_id_two as logger_project
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
		tr.priority
         from pm_tasks_revisionsx tr
         LEFT JOIN
         pm_task_assignment ta ON tr.item_id = ta.task_id) t 
           LEFT JOIN 
           persons u 
           ON 
           t.party_id = u.person_id 
           LEFT JOIN
           pm_roles r
           ON t.role_id = r.role_id,  
        cr_items i 
           LEFT JOIN 
           pm_task_dependency d 
           ON 
           i.item_id = d.task_id,
        pm_tasks_active ti,
        pm_task_status s,
        pm_projectsx p,
	acs_rels ar,
	acs_objects o
	WHERE
        t.parent_id     = p.item_id and
        t.revision_id   = i.live_revision and
        t.item_id       = ti.task_id and
        ti.status       = s.status_id
	and ar.object_id_one = t.parent_id
	and ar.rel_type = 'application_data_link'
	and o.object_id = ar.object_id_two
	and o.object_type = 'logger_project'
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = ti.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
	$done_clause
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
</fullquery>

<fullquery name="tasks_pagination">
    <querytext>
     select distinct task_item_id from (SELECT
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
		tr.priority
         from pm_tasks_revisionsx tr
         LEFT JOIN
         pm_task_assignment ta ON tr.item_id = ta.task_id) t 
           LEFT JOIN 
           persons u 
           ON 
           t.party_id = u.person_id 
           LEFT JOIN
           pm_roles r
           ON t.role_id = r.role_id,  
        cr_items i 
           LEFT JOIN 
           pm_task_dependency d 
           ON 
           i.item_id = d.task_id,
        pm_tasks_active ti,
        pm_task_status s,
        pm_projectsx p
	WHERE
        t.parent_id     = p.item_id and
        t.revision_id   = i.live_revision and
        t.item_id       = ti.task_id and
        ti.status       = s.status_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = ti.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
	$done_clause
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -name tasks -orderby]) t
    </querytext>
</fullquery>

</queryset>
