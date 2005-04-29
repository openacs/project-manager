<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-10-21 -->
<!-- @arch-tag: f8ab4137-d4b8-48a2-a530-bc5d0cb4a4ce -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.3</version>
  </rdbms>

  <fullquery name="instances">
    <querytext>
    SELECT 
    i.name || ' (' || i.instance_id || ')' as name,
    i.project_item_id as my_project_id,
    i.instance_id,
    pr.title as project_name
    FROM 
    pm_process_instance i,
    cr_items pi,
    cr_revisions pr
    WHERE 
    i.project_item_id = pi.item_id and
    pi.live_revision = pr.revision_id and
    i.instance_id in 
    (select 
     t.process_instance 
     from 
     pm_tasks_active t, 
     pm_task_status s 
     where 
     t.status = s.status_id and 
     t.process_instance is not null and 
     s.status_type = 'o')
    ORDER BY
    name
    </querytext>
  </fullquery>
  
</queryset>
