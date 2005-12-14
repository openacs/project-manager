<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.0</version></rdbms>

<fullquery name="tasks">
    <querytext>
        SELECT ts.task_id as task_item_id,
               ts.task_number,
               t.task_revision_id,
               t.title,
               t.description,
               t.parent_id as project_item_id,
               r.object_id_two as logger_project,
               proj_rev.title as project_name,
               to_char(t.earliest_start,'J') as earliest_start_j,
               to_char(sysdate,'J') as today_j,
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
               substr(r.one_line,1,1) as role
        FROM  pm_tasks_active ts, 
              cr_items i,
              pm_tasks_revisionsx t ,
              pm_task_assignment ta ,
              persons p ,
              pm_roles r ,
              cr_items proj,
              pm_projectsx proj_rev,
	      acs_data_links ar,
	      acs_objects o
        WHERE t.item_id = ta.task_id (+) and
              ta.party_id = p.person_id (+) and
              ta.role_id = r.role_id (+) and 
              ts.task_id  = t.item_id and
              i.item_id   = t.item_id and
              t.task_revision_id = i.live_revision and 
              t.parent_id = proj.item_id and
              proj.live_revision = proj_rev.revision_id and
	      ar.object_id_one = t.parent_id and
	      o.object_id = ar.object_id_two and
	      o.object_type = 'logger_project'
              [template::list::filter_where_clauses -and -name tasks]
              [template::list::orderby_clause -orderby -name tasks]
    </querytext>
</fullquery>

</queryset>
