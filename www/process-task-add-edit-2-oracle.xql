<?xml version="1.0"?>
<queryset>
  <fullquery name="new_task">
    <querytext>
        INSERT into pm_process_task 
        (process_task_id,
         process_id,
         one_line,
         description,
         estimated_hours_work,
         estimated_hours_work_min,
         estimated_hours_work_max,
         ordering)
        values
        (:task_id,
         :process_id,
         :one_line,
         :desc,
         :work,
         :work_min,
         :work_max,
         :order)
    </querytext>
  </fullquery>

  <fullquery name="edit_task">
    <querytext>
        UPDATE pm_process_task 
        SET    one_line = :one_line,
               description              = :desc,
               estimated_hours_work     = :work,
               estimated_hours_work_min = :work_min,
               estimated_hours_work_max = :work_max,
               ordering                 = :order
        WHERE  process_task_id = :task_id
    </querytext>
  </fullquery>

  <fullquery name="editing_process_tasks_p">
    <querytext>
        SELECT count(*) 
        FROM pm_process_task 
        WHERE  process_task_id in ([join $process_task_id ","])
    </querytext>
  </fullquery>

</queryset>
