<?xml version="1.0"?>
<queryset>

  <fullquery name="get_people">
    <querytext>
      SELECT
      a.party_id,
      a.role_id
      FROM
      pm_task_assignment a,
      cr_items i
      WHERE
      i.parent_id = :project_item_id and
      i.item_id = a.task_id
    </querytext>
  </fullquery>

</queryset>
