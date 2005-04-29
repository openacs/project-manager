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

</queryset>
