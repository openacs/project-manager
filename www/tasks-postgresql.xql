<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="tasks">
    <querytext>
        SELECT
        ts.task_id,
        ts.task_number,
        t.task_revision_id,
        t.title,
        t.description,	
	tst.description as status,
        t.parent_id as project_item_id,
        ar.object_id_two as logger_project,
        proj_rev.title as project_name,
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
        r.one_line as role
        FROM
        pm_tasks_active ts, 
	pm_task_status tst,
        cr_items i,
        pm_tasks_revisionsx t 
          LEFT JOIN pm_task_assignment ta
          ON t.item_id = ta.task_id
            LEFT JOIN persons p 
            ON ta.party_id = p.person_id
            LEFT JOIN pm_roles r
            ON ta.role_id = r.role_id,
        cr_items proj,
	cr_folders f,
        pm_projectsx proj_rev,
	acs_data_links ar,
	acs_objects o
        WHERE
        ts.task_id  = t.item_id and
	tst.status_id = status and
        i.item_id   = t.item_id and
        t.task_revision_id = i.live_revision and 
        t.parent_id = proj.item_id and
        proj.live_revision = proj_rev.revision_id
	and proj.parent_id = f.folder_id
        and f.package_id = :package_id
	and ar.object_id_one = t.parent_id
	and o.object_id = ar.object_id_two
	and o.object_type = 'logger_project'
	[template::list::page_where_clause -and -name "tasks" -key "ts.task_id"]
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = ts.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -orderby -name tasks]
    </querytext>
</fullquery>

<fullquery name="tasks_pagination">
    <querytext>
     select distinct task_id from (
        SELECT
	ts.task_id
        FROM
        pm_tasks_active ts, 
        cr_items i,
        pm_tasks_revisionsx t 
          LEFT JOIN pm_task_assignment ta
          ON t.item_id = ta.task_id
            LEFT JOIN persons p 
            ON ta.party_id = p.person_id
            LEFT JOIN pm_roles r
            ON ta.role_id = r.role_id,
        cr_items proj,
	cr_folders f,
        pm_projectsx proj_rev
        WHERE
        ts.task_id  = t.item_id and
        i.item_id   = t.item_id and
        t.task_revision_id = i.live_revision and 
        t.parent_id = proj.item_id and
        proj.live_revision = proj_rev.revision_id
	and proj.parent_id = f.folder_id
        and f.package_id = :package_id 
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -orderby -name tasks]) as tasks
    </querytext>
</fullquery>

</queryset>
