<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.0</version></rdbms>

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
        WHERE  t.item_id = :task_item_id and
               t.item_id = i.item_id and
               i.live_revision = t.revision_id
    </querytext>
  </fullquery>

</queryset>
