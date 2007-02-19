<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-08-04 -->
<!-- @arch-tag: 201543cc-5c43-4eae-b07a-1999b8752fff -->
<!-- @cvs-id $Id$ -->

<queryset>
   <rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="pm::calendar::one_month_display.select_monthly_tasks">
<querytext>
      SELECT
      ts.task_id,
      ts.task_id as item_id,
      ts.task_number,
      t.task_revision_id,
      t.title,
      o.package_id as instance_id,
      t.parent_id as project_item_id,
      to_char(t.earliest_start,'J') as earliest_start_j,
      to_char(current_timestamp,'J') as today_j,
      to_char(t.latest_start,'J') as latest_start_j,
      to_char(t.latest_finish,'J') as latest_finish_j,
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
      p.first_names || ' ' || p.last_name || ' (' ||
        substring(r.one_line from 1 for 1) || ')' as full_name,
      p.person_id,
      s.status_type as status,
      r.is_lead_p,
      projectr.title as project_name
      FROM
      acs_objects o,
      pm_tasks_active ts, 
      pm_task_status s,
      cr_items i,
      pm_tasks_revisionsx t 
        LEFT JOIN pm_task_assignment ta
        ON t.item_id = ta.task_id
          LEFT JOIN persons p 
          ON ta.party_id = p.person_id
          LEFT JOIN pm_roles r
          ON ta.role_id = r.role_id,
      cr_items     projecti,
      cr_revisions projectr
      WHERE
      ts.status   = s.status_id and
      ts.task_id  = t.item_id and
      i.item_id   = t.item_id and
      t.task_revision_id = i.live_revision and
      t.end_date >= :first_of_month_date and
      t.end_date <= :last_of_month_date and
      t.parent_id = projecti.item_id and
      o.object_id=t.item_id and
      projecti.live_revision = projectr.revision_id
      $instance_clause
      $hide_closed_clause
      $selected_users_clause
      ORDER BY
      t.latest_start, ts.task_id, r.role_id, p.first_names, p.last_name
</querytext>
</fullquery>


<fullquery name="pm::calendar::one_month_display.select_monthly_tasks_by_deadline">
<querytext>
	SELECT        t.item_id as task_id,
        t.parent_id as project_item_id,
        t.title,
	to_char(t.end_date,'YYYY-MM-DD HH24:MI:SS') as day_date,
	to_char(t.end_date,'J') as day_date_j,
        s.status_type as status,
        s.description as status_description,
 	t.priority,
	t.parent_id,
	r.is_lead_p,
	op.title as project_name,
	op.package_id as instance_id,
	ta.party_id as person_id
	FROM
 (select tr.*
  from cr_items ci, pm_tasks_revisionsx tr
  -- get only live revisions
  where ci.live_revision = tr.task_revision_id) t,
	pm_tasks_active ti,
        pm_task_status s,
        pm_task_assignment ta,
	pm_roles r,
        cr_items cp,
        acs_objects op
         where t.parent_id     = cp.item_id and
        t.item_id       = ti.task_id and
        ti.status       = s.status_id
        and cp.live_revision = op.object_id
	and t.item_id = ta.task_id and ta.role_id = r.role_id and ta.party_id in ([join $selected_users ","])
	and s.status_type = 'o'
      $hide_closed_clause
      $instance_clause
      and t.end_date >= :first_of_month_date
      and t.end_date <= :last_of_month_date
      ORDER BY
      t.end_date
</querytext>
</fullquery>

<fullquery name="pm::calendar::one_month_project_display.select_monthly_projects_by_deadline">
<querytext>
        SELECT
        p.item_id as project_item_id,
        p.project_id,
	p.status_id,
        p.parent_id as folder_id,
        p.object_type as content_type,
        p.title as project_name,
        p.project_code,
	f.package_id as instance_id,
        to_char(p.planned_start_date, 'MM/DD/YY') as planned_start_date,
        to_char(p.planned_end_date, 'MM/DD/YY') as planned_end_date,
        p.ongoing_p,
        c.category_id,
        c.category_name,
	to_char(p.planned_end_date,'J') as deadline_j,
        p.earliest_finish_date - current_date as days_to_earliest_finish,
        p.latest_finish_date - current_date as days_to_latest_finish,
        p.actual_hours_completed,
        p.estimated_hours_total,
        to_char(p.estimated_finish_date, 'MM/DD/YY') as estimated_finish_date,
        to_char(p.earliest_finish_date, 'MM/DD/YY') as earliest_finish_date,
        to_char(p.latest_finish_date, 'MM/DD/YY') as latest_finish_date,
	persons.first_names || ' ' || persons.last_name || ' (' ||
        substring(r.one_line from 1 for 1) || ')' as full_name,
        persons.person_id,
        case when o.name is null then '--no customer--' else o.name
                end as customer_name,
        o.organization_id as customer_id
        FROM pm_projectsx p 
             LEFT JOIN pm_project_assignment pa 
                ON p.item_id = pa.project_id	
             LEFT JOIN persons 
             ON pa.party_id = persons.person_id
                LEFT JOIN pm_roles r
                 ON pa.role_id = r.role_id
             LEFT JOIN organizations o ON p.customer_id =
                o.organization_id 
             LEFT JOIN (
                        select 
                        om.category_id, 
                        om.object_id, 
                        t.name as category_name 
                        from 
                        category_object_map om, 
                        category_translations t, 
                        categories ctg 
                        where 
                        om.category_id = t.category_id and 
                        ctg.category_id = t.category_id and 
                        ctg.deprecated_p = 'f')
                 c ON p.item_id = c.object_id, 
        cr_items i, 
	cr_folders f
        WHERE 
        p.project_id = i.live_revision 
	and i.parent_id = f.folder_id
	$instance_clause
	$selected_users_clause
        and exists (select 1 from acs_object_party_privilege_map ppm 
                    where ppm.object_id = p.project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
       </querytext>
</fullquery>

</queryset>
