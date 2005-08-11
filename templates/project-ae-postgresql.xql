<?xml version="1.0"?>
<queryset>
  <fullquery name="project_query">
    <querytext>
        SELECT
        p.item_id as project_item_id,
        p.parent_id,
 	p.project_id,
        p.title as project_name,
        p.project_code,
 	p.goal,
 	p.description,
        p.customer_id,
        p.status_id,
 	to_char(p.planned_start_date,'YYYY-MM-DD') as planned_start_date,
 	to_char(p.planned_end_date,'YYYY-MM-DD HH24:MI:SS') as planned_end_date,
 	p.ongoing_p,
	p.dform
        FROM
 	pm_projectsx p
        WHERE 
        p.item_id    = :project_item_id and
        p.project_id = :project_id 
    </querytext>
  </fullquery>

  <fullquery name="do_nothing">
    <querytext>
        SELECT
        current_timestamp
    </querytext>
  </fullquery>

  <fullquery name="get_customer_id">
    <querytext>
	select customer_id
	from pm_projects
	where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="get_status_codes">
    <querytext>
	SELECT
        description, status_id
	FROM
	pm_project_status
        ORDER BY
        status_type desc, description asc
    </querytext>
  </fullquery>

</queryset>
