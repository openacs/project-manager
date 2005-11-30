<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-04-30 -->
<!-- @arch-tag: a0198eb4-fce3-4e48-b230-a641347e42ed -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <fullquery name="project_revisions_query">
    <querytext>
      SELECT p.item_id,
             p.project_id,
             p.title as project_name,
             p.project_code,
             p.goal,
             p.description,
             p.mime_type,
             to_char(p.planned_start_date,'Mon DD') as planned_start_date,
             to_char(p.planned_end_date,'Mon DD') as planned_end_date,
             p.ongoing_p,
             i.live_revision,
             to_char(p.estimated_finish_date,'Mon DD') as estimated_finish_date,
             to_char(p.earliest_finish_date,'Mon DD') as earliest_finish_date,
             to_char(p.latest_finish_date,'Mon DD') as latest_finish_date,
             p.estimated_hours_total
      FROM  pm_projectsx p, 
            cr_items i
      WHERE p.item_id = :project_item_id and 
            p.item_id = i.item_id
      ORDER BY p.project_id asc
    </querytext>
  </fullquery>

</queryset>

