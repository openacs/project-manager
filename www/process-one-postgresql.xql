<?xml version="1.0"?>
<queryset>

  <fullquery name="task_query">
    <querytext>
	SELECT
        t.process_task_id,
        t.one_line,
        t.description,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        d.dependency_type,
        t.ordering,
        p.first_names,
        p.last_name,
        p.person_id
	FROM
        pm_process_task t 
          LEFT JOIN
          pm_process_task_assignment a
          ON 
          t.process_task_id = a.process_task_id
            LEFT JOIN
            pm_roles r
            ON r.role_id = a.role_id
          LEFT JOIN 
          persons p 
          ON p.person_id = a.party_id
          LEFT JOIN 
          pm_process_task_dependency d 
          ON t.process_task_id = d.process_task_id 
	WHERE
	t.process_id = :process_id and
        (r.is_lead_p = 't' or r.is_lead_p is null)
        [template::list::orderby_clause -orderby -name tasks]
    </querytext>
  </fullquery>

</queryset>
