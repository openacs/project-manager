<?xml version="1.0"?>
<queryset>

  <fullquery name="get_process_tasks">
    <querytext>
	SELECT t.process_task_id as pti,
               t.one_line,
               t.description,
               t.estimated_hours_work,
               t.estimated_hours_work_min,
               t.estimated_hours_work_max,
               d.dependency_type,
               t.ordering
	FROM  pm_process_task t ,
              pm_process_task_dependency d    
        WHERE  t.process_task_id = d.process_task_id (+) and 
               t.process_task_id in ([join $process_task_id ", "])
        ORDER BY t.ordering, 
                 t.process_task_id
    </querytext>
  </fullquery>


</queryset>
