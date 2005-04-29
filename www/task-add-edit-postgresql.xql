<?xml version="1.0"?>
<queryset>
  <fullquery name="task_query">
    <querytext>
      select
        current_timestamp
    </querytext>
  </fullquery>

  <fullquery name="get_old_tasks">
    <querytext>
        select
        t.parent_id as my_project_item_id,
        t.task_revision_id,
        t.title as my_task_title,
        t.description as my_description,
        t.mime_type as my_mime_type,
        to_char(t.end_date,'YYYY MM DD') as my_end_date,
        t.percent_complete as my_percent_complete,
        t.estimated_hours_work as my_estimated_work,
        t.estimated_hours_work_min as my_estimated_work_min,
        t.estimated_hours_work_max as my_estimated_work_max,
        t.actual_hours_worked as my_actual_hours_worked,
        d.parent_task_id as my_dependency
        FROM
        pm_tasks_revisionsx t, 
        cr_items i LEFT JOIN pm_task_dependency d ON i.item_id = d.task_id
        WHERE
        t.item_id in ([join $task_id ","]) and
        t.revision_id = i.live_revision
        ORDER BY
        t.item_id
    </querytext>
  </fullquery>

  <fullquery name="get_project_id">
    <querytext>
        SELECT
        p.project_id
        FROM
        pm_projectsx p, cr_items i
        WHERE
        p.item_id = :project_item_id and 
        p.revision_id = i.live_revision
    </querytext>
  </fullquery>

  <fullquery name="get_dependency_types">
    <querytext>
      select
        short_name,
        description
	FROM
	pm_task_dependency_types
        ORDER BY
        short_name
    </querytext>
  </fullquery>

  <fullquery name="get_task_item_id">
    <querytext>
      select
        item_id
	FROM
	pm_tasks_revisionsx
        WHERE
        revision_id = :this_revision_id
    </querytext>
  </fullquery>

</queryset>
