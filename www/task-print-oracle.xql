<?xml version="1.0"?>
<queryset>

  <fullquery name="get_revision_id">
    <querytext>
        SELECT  t.revision_id as task_revision_id
        FROM    pm_tasks_revisionsx t, cr_items i
        WHERE   t.item_id = :task_id and
                i.live_revision = t.revision_id
    </querytext>
  </fullquery>

  <fullquery name="get_project_ids">
    <querytext>
        SELECT t.parent_id as project_item_id
        FROM   pm_tasks_revisionsx t, cr_items i
        WHERE  i.item_id = t.item_id and
               t.revision_id = :task_revision_id
    </querytext>
  </fullquery>

  <fullquery name="task_query">
    <querytext>
        SELECT t.item_id,
               t.title as task_title,
               t.description,
               t.mime_type,
               to_char(current_timestamp,'Mon DD ''YY') as current_time,
               to_char(t.earliest_start,'Mon DD ''YY') as earliest_start,
               to_char(t.earliest_start,'J') as earliest_start_j,
               to_char(t.earliest_finish,'Mon DD ''YY') as earliest_finish,
               to_char(t.latest_start,'Mon DD ''YY') as latest_start,
               to_char(t.latest_start,'J') as latest_start_j,
               to_char(t.latest_finish,'Mon DD ''YY') as latest_finish,
               to_char(current_date,'J') as today_j,
               t.estimated_hours_work,
               t.estimated_hours_work_min,
               t.estimated_hours_work_max,
               t.percent_complete,
               i.live_revision
        FROM   pm_tasks_revisionsx t, cr_items i
        WHERE  t.item_id = :task_id and
               t.revision_id = :task_revision_id and
               t.item_id = i.item_id
    </querytext>
  </fullquery>


  <fullquery name="dependency_query">
    <querytext>
        SELECT t.title as task_title,
               to_char(t.end_date,'MM/DD/YYYY') as end_date,
               t.percent_complete,
               i.live_revision,
               d.parent_task_id,
               d.dependency_type
        FROM   pm_tasks_revisionsx t, 
               cr_items i, 
               pm_task_dependency d
        WHERE  d.task_id        = :task_id and
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
               d.task_id
        FROM   pm_tasks_revisionsx t, cr_items i, pm_task_dependency d
        WHERE d.task_id        = t.item_id and
              d.parent_task_id = :task_id and 
              t.revision_id    = i.live_revision and
              t.item_id        = i.item_id
              [template::list::orderby_clause -name dependency2 -orderby]
    </querytext>
  </fullquery>

  <fullquery name="task_people_query">
    <querytext>
        SELECT r.one_line,
               u.first_names || ' ' || u.last_name as user_info,
               r.role_id
        FROM   pm_task_assignment a,
               cc_users u,
               pm_roles r
        WHERE  a.task_id  = :task_id and
               u.party_id = a.party_id and
               a.role_id  = r.role_id
    </querytext>
  </fullquery>

</queryset>
