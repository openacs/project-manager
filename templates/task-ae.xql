<?xml version="1.0"?>
<queryset>

  <fullquery name="task_data">
    <querytext>
	select i.latest_revision as task_id, t.parent_id as project_item_id
	from cr_items i, pm_tasks_revisionsx t
	where i.item_id = :task_item_id
	and t.object_id = i.latest_revision
    </querytext>
  </fullquery>

  <fullquery name="get_dynamic_form">
    <querytext>
	select dform
	from pm_tasks_revisions
	where task_revision_id = :task_id
    </querytext>
  </fullquery>

  <fullquery name="get_task_data">
    <querytext>
	select title as task_title, description as description_content, mime_type as description_mime_type,
	       percent_complete, to_char(end_date,'YYYY-MM-DD HH24:MI:SS') as task_end_date,
	       estimated_hours_work, estimated_hours_work_min,
	       estimated_hours_work_max, priority
	from pm_tasks_revisionsi
	where object_id = :task_id
    </querytext>
  </fullquery>

  <fullquery name="get_item_id">
    <querytext>
	    select item_id
	    from cr_revisions
	    where revision_id = :task_id
    </querytext>
  </fullquery>

  <fullquery name="new_task">
    <querytext>
	    insert into pm_tasks
	    (task_id, task_number, status, process_instance)
	    values
	    (:task_item_id, 1, :status_id, :process_instance_id)
    </querytext>
  </fullquery>

  <fullquery name="update_task">
    <querytext>
	    update pm_tasks
	    set status = :status_id
	    where task_id = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="update_parent_id">
    <querytext>
	    update cr_items
	    set parent_id = :project_item_id
	    where item_id = :task_item_id
    </querytext>
  </fullquery>

</queryset>
