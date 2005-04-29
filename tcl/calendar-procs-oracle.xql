<?xml version="1.0"?>
<!--  -->
<!-- @author Khy H (khuang@mednet.ucla.edu) -->
<!-- @creation-date 2004-08-04 -->
<!-- @arch-tag: 201543cc-5c43-4eae-b07a-1999b8752fff -->
<!-- @cvs-id $Id$ -->

<queryset>
   <rdbms><type>oracle</type><version>8.0</version></rdbms>

<fullquery name="pm::calendar::one_month_display.select_monthly_tasks">
<querytext>
      SELECT ts.task_id,
             ts.task_id as item_id,
             ts.task_number,
             t.task_revision_id,
             t.title,
             t.parent_id as project_item_id,
             to_char(t.earliest_start,'J') as earliest_start_j,
             to_char(sysdate,'J') as today_j,
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
               substr(r.one_line,1,1) || ')' as full_name,
             p.person_id,
             s.status_type as status,
             r.is_lead_p,
             projectr.title as project_name
      FROM  pm_tasks_active ts, 
            pm_task_status s,
            cr_items i,
            pm_tasks_revisionsx t, 
            pm_roles r, 
            persons p, 
            pm_task_assignment ta,
            cr_items projecti,
            cr_revisions projectr
      WHERE ta.role_id = r.role_id (+) and
          t.item_id = ta.task_id (+)  and 
          ta.party_id = p.person_id (+) and 
          ta.role_id = r.role_id and        
          ts.status   = s.status_id and
          ts.task_id  = t.item_id and
          i.item_id   = t.item_id and
          t.task_revision_id = i.live_revision and
          t.latest_start >= :first_of_month_date and
          t.latest_start <= :last_of_month_date and
          t.parent_id = projecti.item_id and
          projecti.live_revision = projectr.revision_id
          $hide_closed_clause
          $selected_users_clause
      ORDER BY
          t.latest_start, ts.task_id, r.role_id, p.first_names, p.last_name
</querytext>
</fullquery>


</queryset>
