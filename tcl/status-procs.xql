<?xml version="1.0"?>

<queryset>

  <fullquery name="pm::status::open_p.get_open_p">
    <querytext>
        SELECT
        case when status_type = 'c' then 'f' else 't' end
        FROM
        pm_task_status
        WHERE
        status_id = :task_status_id
    </querytext>
  </fullquery>

  <fullquery name="pm::status::project_status_select_helper.get_status">
    <querytext>
        SELECT 
          description, status_id 
        FROM 
          pm_project_status 
	ORDER BY 
          status_type desc, description
    </querytext>
  </fullquery>

</queryset>
