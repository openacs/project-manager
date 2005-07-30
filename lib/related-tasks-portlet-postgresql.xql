<?xml version="1.0"?>
<queryset>

  <fullquery name="related_tasks_query">
    <querytext>
      SELECT
      x.task_id_1 as x_task_id,
      r.title,
        to_char(r.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
        r.earliest_start - current_date as days_to_earliest_start,
        to_char(r.earliest_start,'J') as earliest_start_j,
        to_char(r.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
        r.earliest_finish - current_date as days_to_earliest_finish,
        to_char(r.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
        r.latest_start - current_date as days_to_latest_start,
        to_char(r.latest_start,'J') as latest_start_j,
        to_char(current_date,'J') as today_j,
        to_char(r.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
        r.latest_finish - current_date as days_to_latest_finish
      FROM
      pm_task_xref x, pm_tasks_revisionsx r, cr_items i
      WHERE
      x.task_id_2      = :task_id and
      x.task_id_1      = r.item_id and
      r.revision_id    = i.live_revision
      UNION
      SELECT
      x2.task_id_2 as x_task_id,
      r2.title,
        to_char(r2.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
        r2.earliest_start - current_date as days_to_earliest_start,
        to_char(r2.earliest_start,'J') as earliest_start_j,
        to_char(r2.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
        r2.earliest_finish - current_date as days_to_earliest_finish,
        to_char(r2.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
        r2.latest_start - current_date as days_to_latest_start,
        to_char(r2.latest_start,'J') as latest_start_j,
        to_char(current_date,'J') as today_j,
        to_char(r2.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
        r2.latest_finish - current_date as days_to_latest_finish
      FROM
      pm_task_xref x2, pm_tasks_revisionsx r2, cr_items i2
      WHERE
      x2.task_id_1      = :task_id and
      x2.task_id_2      = r2.item_id and
      i2.live_revision  = r2.revision_id
    </querytext>
  </fullquery>

</queryset>
