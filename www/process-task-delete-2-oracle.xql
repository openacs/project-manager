<?xml version="1.0"?>
<queryset>

  <fullquery name="delete_process_tasks">
    <querytext>
        DELETE FROM  pm_process_task
        WHERE process_task_id in ([join $process_task_id ", "])
    </querytext>
  </fullquery>


</queryset>
