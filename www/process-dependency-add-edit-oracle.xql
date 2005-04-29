<?xml version="1.0"?>
<queryset>
  <fullquery name="dependency_query">
    <querytext>
      SELECT t.process_task_id as task_id,
             t.one_line as task_title,
             t.description,
             d.parent_task_id
      FROM pm_process_task t ,
           pm_process_task_dependency d 
      WHERE t.process_task_id = d.process_task_id (+) and 
            t.process_task_id in ([join $use_dependency_list ", "])
      ORDER BY t.ordering, t.process_task_id
    </querytext>
  </fullquery>

  <fullquery name="get_dependency_types">
    <querytext>
      SELECT short_name,
             description
      FROM   pm_task_dependency_types
      ORDER BY short_name
    </querytext>
  </fullquery>

  <fullquery name="get_dependency_tasks">
    <querytext>
      SELECT process_task_id as task_id, 
             one_line as task_title        
      FROM   pm_process_task
      WHERE  process_id = :process_id
      ORDER BY  ordering
    </querytext>
  </fullquery>

</queryset>
