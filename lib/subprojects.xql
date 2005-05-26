<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/subprojects.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-01 -->
<!-- @arch-tag: e7de2d65-12c2-4a62-9439-863c859151ee -->
<!-- @cvs-id $Id$ -->

<queryset>
  <fullquery name="project_subproject_query">
    <querytext>
        SELECT
	p.item_id,
        p.project_id,
        p.parent_id as folder_id,
	p.object_type as content_type,
	p.title as project_name,
	p.project_code,
	to_char(p.planned_start_date, 'Mon DD') as planned_start_date,
	to_char(p.planned_end_date, 'Mon DD') as planned_end_date,
	p.ongoing_p,
        p.actual_hours_completed,
        p.estimated_hours_total
        FROM pm_projectsx p, cr_items i
        WHERE p.project_id = i.live_revision and
        p.parent_id = :project_item_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :project_item_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        ORDER BY p.title
    </querytext>
  </fullquery>

</queryset>