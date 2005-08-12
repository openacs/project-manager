<?xml version="1.0"?>

<!-- @author  (jader-ibr@bread.com) -->
<!-- @creation-date 2004-11-18 -->
<!-- @arch-tag: 9e1e983e-49f7-476e-ace6-4879f552bc76 -->
<!-- @cvs-id $Id$ -->

<queryset>

  <fullquery name="pm::task::assign_remove_everyone.remove_assignment">
    <querytext>
      DELETE FROM 
      pm_task_assignment 
      WHERE 
      task_id  = :task_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::unassign.remove_assignment">
    <querytext>
      DELETE FROM 
      pm_task_assignment 
      WHERE 
      task_id  = :task_item_id and
      party_id = :party_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::assigned_p.assigned_p">
    <querytext>
      SELECT
      party_id
      FROM
      pm_task_assignment
      WHERE
      task_id  = :task_item_id and
      party_id = :party_id
      LIMIT 1
    </querytext>
  </fullquery>

  <fullquery name="pm::task::move.get_project_package_id">
    <querytext>
	select 
		package_id 
	from 
		acs_objects 
	where 
		object_id =:project_item_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::move.update_extra_info">
    <querytext>
	update 
		pm_tasks
	set 
		task_number = 1, 
		status = 1
	where
		task_id = :new_task_id
    </querytext>
  </fullquery>

  <fullquery name="pm::task::move.get_original_times">
    <querytext>
	select
		earliest_start,
 		earliest_finish,
 		latest_start,
	 	latest_finish
	from
		pm_tasks_revisions
	where
		task_revision_id = :task_revision_id
    </querytext>
  </fullquery>


  <fullquery name="pm::task::move.update_task_times">
    <querytext>
	update 
		pm_tasks_revisions
	set 
		earliest_start  = :earliest_start,
 		earliest_finish = :earliest_finish,
 		latest_start    = :latest_start,
	 	latest_finish   = :latest_finish
	where
		task_revision_id = :new_task_revision_id
    </querytext>
  </fullquery>


</queryset>
