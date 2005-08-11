<?xml version="1.0"?>
<queryset>

  <fullquery name="project_query">
    <querytext>
	SELECT  p.item_id,
	        p.project_id,
	        p.title as project_name,
	        p.project_code,
	        p.goal,
	        p.description,
                p.mime_type, 
 	        to_char(p.planned_start_date,'YYYY-MM-DD HH24:MI') as planned_start_date,
	        to_char(p.planned_end_date,'YYYY-MM-DD HH24:MI') as planned_end_date,
	        p.ongoing_p,
                i.live_revision,
                to_char(p.estimated_finish_date,'YYYY-MM-DD HH24:MI') as estimated_finish_date,
                to_char(p.earliest_finish_date,'YYYY-MM-DD HH24:MI') as earliest_finish_date,
                to_char(p.latest_finish_date,'YYYY-MM-DD HH24:MI') as latest_finish_date,
                p.actual_hours_completed,
                p.estimated_hours_total,
                p.parent_id
	FROM    pm_projectsx p, cr_items i
	WHERE   p.item_id = :project_item_id and
                p.project_id = :project_id and
                p.item_id = i.item_id
    </querytext>
  </fullquery>

  <fullquery name="project_tasks_query">
    <querytext>
	SELECT t.item_id as task_id,
               t.title,
	       to_char(t.end_date,'YYYY-MM-DD HH24:MI') as end_date,
	       to_char(t.earliest_start,'YYYY-MM-DD HH24:MI') as earliest_start,
	       t.earliest_start - sysdate as days_to_earliest_start,
	       to_char(t.earliest_start,'J') as earliest_start_j,
	       to_char(t.earliest_finish,'YYYY-MM-DD HH24:MI') as earliest_finish,
	       t.earliest_finish - sysdate as days_to_earliest_finish,
	       to_char(t.latest_start,'YYYY-MM-DD HH24:MI') as latest_start,
	       t.latest_start - sysdate as days_to_latest_start,
	       to_char(t.latest_start,'J') as latest_start_j,
	       to_char(sysdate,'J') as today_j,
	       to_char(t.latest_finish,'YYYY-MM-DD HH24:MI') as latest_finish,
	       t.latest_finish - sysdate as days_to_latest_finish,
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
               s.description as status_description
	FROM   (SELECT * 
                 FROM  pm_tasks_revisionsx tk,
                       pm_task_assignment asg
                 WHERE tk.item_id = asg.task_id (+)
               ) t ,
               persons u,
               cr_items i, 
               pm_tasks_active ti,
               pm_task_status s ,
               pm_task_dependency d 
	WHERE i.item_id = d.task_id (+) and 
              t.party_id = u.person_id (+) and 
              t.parent_id = :project_item_id and
              t.revision_id = i.live_revision and
              t.item_id     = ti.task_id and
              ti.status     = s.status_id
        [template::list::orderby_clause -name tasks -orderby]
    </querytext>
  </fullquery>

  <fullquery name="get_root_folder">
    <querytext>
        begin
            :1 := pm_project.get_root_folder (:package_id, 'f');
        end;
    </querytext>
  </fullquery>

<fullquery name="project_subproject_query">
    <querytext>
        SELECT 	p.item_id,
                p.project_id,
                p.parent_id as folder_id,
	        p.object_type as content_type,
	        p.title as project_name,
	        p.project_code,
	        to_char(p.planned_start_date, 'Mon DD') as planned_start_date,
	        to_char(p.planned_end_date, 'Mon DD') as planned_end_date,
	        p.ongoing_p,
                p.actual_hours_completed,
                p.estimated_hours_total
        FROM    pm_projectsx p, 
                cr_items i
        WHERE p.project_id = i.live_revision and
              p.parent_id = :project_item_id
        ORDER BY p.title
    </querytext>
  </fullquery>

  <fullquery name="project_people_query">
    <querytext>
        SELECT  a.project_id,
                r.one_line as role_name,
                p.first_names || ' ' || p.last_name as user_name
        FROM    pm_project_assignment a,
                pm_roles r,
                persons p
        WHERE   a.role_id = r.role_id and
                a.party_id = p.person_id and
                project_id = :project_item_id
        ORDER BY r.role_id, 
                 p.first_names, 
                 p.last_name
    </querytext>
  </fullquery>

  <fullquery name="custom_query">
    <querytext>
        SELECT  p.customer_id,
                c.name as customer_name
        FROM    pm_projectsx p ,
                organizations c 
        WHERE p.customer_id = c.organization_id (+)  and 
        p.project_id = :original_project_id
    </querytext>
  </fullquery>

</queryset>
