<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-04-30 -->
<!-- @arch-tag: a0198eb4-fce3-4e48-b230-a641347e42ed -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>oracle</type>
    <version>8.0</version>
  </rdbms>
  
  <fullquery name="task_revisions_query">
    <querytext>
	SELECT t.item_id,
               t.revision_id,
               i.live_revision,
               t.title as task_title,
               t.description || ' -- ' || p.first_names || ' ' || p.last_name as description,
               t.mime_type,
	       to_char(t.end_date,'MM/DD/YYYY') as end_date,
               t.percent_complete,
               t.estimated_hours_work_min,
               t.estimated_hours_work_max,
               t.actual_hours_worked        
	FROM   pm_tasks_revisionsx t, cr_items i, persons p
	WHERE  t.item_id = :task_id and
               t.item_id = i.item_id and
               t.creation_user = p.person_id
        ORDER BY t.revision_id asc
    </querytext>
  </fullquery>

</queryset>

