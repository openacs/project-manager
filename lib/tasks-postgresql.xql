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
 	t.priority,
	t.parent_id,
	op.title as project_name
	FROM
 (select tr.*
  from cr_items ci, pm_tasks_revisionsx tr
  -- get only live revisions
  where ci.live_revision = tr.task_revision_id
 [template::list::page_where_clause -and -name "tasks" -key "ci.item_id"]) t,
	pm_tasks_active ti,
        pm_task_status s,
        $observer_from_clause
        cr_items cp,
        acs_objects op
         where t.parent_id     = cp.item_id and
        t.item_id       = ti.task_id and
        ti.status       = s.status_id
        and cp.live_revision = op.object_id
	$party_id_clause
	$observer_pagination_clause
	$priority_clause
	[template::list::page_where_clause -and -name "tasks" -key "t.item_id"]
        [template::list::orderby_clause -name tasks -orderby]

    </querytext>
</fullquery>

<fullquery name="tasks_pagination">
    <querytext>
	SELECT  t.item_id as task_item_id
	FROM
 (select ci.parent_id, ci.item_id, ci.latest_revision, tr.end_date, tr.priority, tr.earliest_start, tr.latest_start
  from cr_items ci, pm_tasks_revisions tr
  -- get only live revisions
  where ci.live_revision = tr.task_revision_id
) t, pm_tasks_active ti, $observer_from_clause $search_from_clause
        cr_items cp, acs_objects op, pm_projects p
         where t.parent_id     = cp.item_id
        and t.item_id       = ti.task_id
        and cp.live_revision = p.project_id
        and p.project_id = op.object_id
	$party_id_clause
	$observer_pagination_clause
	$search_where_clause
	$priority_clause
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
</fullquery>

<fullquery name="get_people">
    <querytext>
	select
                distinct(first_names || ' ' || last_name) as fullname,
        	u.person_id
        from
                persons u,
                pm_task_assignment a,
                pm_tasks_active ts
        where
                u.person_id = a.party_id 
                and ts.task_id = a.task_id
        order by
                fullname
    </querytext>
</fullquery>

<fullquery name="get_subprojects">
    <querytext>
	select 
		ci.item_id
	from 
		cr_items ci, 
		pm_projects p, 
		cr_items pi
	where 
		p.project_id = ci.latest_revision
        	and ci.tree_sortkey between tree_left(pi.tree_sortkey) 
		and tree_right(pi.tree_sortkey)
        	and pi.item_id = :pid_filter
    </querytext>
</fullquery>

<fullquery name="get_logger_project">
    <querytext>
	select 
		rel.object_id_two 
	from 
		acs_data_links rel, 
		acs_objects o 
	where
		and object_id_two = o.object_id 
		and o.object_type = 'logger_project'
		and rel.object_id_one = :parent_id
    </querytext>
</fullquery>

<fullquery name="get_status_values">
    <querytext>
	select 
		description, 
		status_id 
	from 
		pm_task_status 
	order by 
		status_type desc, 
		description
    </querytext>
</fullquery>


</queryset>
