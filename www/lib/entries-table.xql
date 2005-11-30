<?xml version="1.0"?>

<queryset>

  <fullquery name="select_variable_info">
    <querytext>
	    select name,
	           unit,
	           type
	    from   logger_variables
	    where  variable_id = :selected_variable_id
    </querytext>
  </fullquery>

  <fullquery name="select_entries">
    <querytext>
        SELECT
        le.entry_id as id,
        acs_permission__permission_p(le.entry_id, :current_user_id, 'delete') as delete_p,
        acs_permission__permission_p(le.entry_id, :current_user_id, 'write') as edit_p,
        le.time_stamp,
        to_char(le.time_stamp, 'fmDyfm fmMMfm-fmDDfm-YYYY') as time_stamp_pretty,
        to_char(le.time_stamp, 'IW-YYYY') as time_stamp_week,
        le.value,
        le.description,
        task.title as project_name,
        submitter.person_id as user_id,
        submitter.first_names || ' ' || submitter.last_name as user_name
        FROM
        logger_entries le
        LEFT JOIN (select 
                   r.title, 
                   m.logger_entry 
                   from 
                   cr_items i, 
                   cr_revisions r,
                   pm_task_logger_proj_map m 
                   where 
                   r.item_id = m.task_item_id and
                   i.live_revision = r.revision_id) task 
                ON le.entry_id = task.logger_entry,
        logger_projects lp,
        acs_objects ao,
        persons submitter
        WHERE 
        le.project_id = lp.project_id and
        ao.object_id = le.entry_id and
        ao.creation_user = submitter.person_id
        [ad_decode $where_clauses "" "" "and [join $where_clauses "\n    and "]"]
        ORDER BY
        $order_by
    </querytext>
  </fullquery>

</queryset>
