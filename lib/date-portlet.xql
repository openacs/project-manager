<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/project-portlet.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-01 -->
<!-- @arch-tag: 91646b9e-e93a-4dca-802d-525e9383f791 -->
<!-- @cvs-id $Id$ -->

<queryset>
    <fullquery name="project_query">
    <querytext>
	SELECT
	to_char(p.planned_start_date,'YYYY-MM-DD HH24:MI:SS') as planned_start_date,
	to_char(p.planned_end_date,'YYYY-MM-DD HH24:MI:SS') as planned_end_date,
	p.ongoing_p,
        to_char(p.estimated_finish_date,'YYYY-MM-DD HH24:MI:SS') as estimated_finish_date,
        to_char(p.earliest_finish_date,'YYYY-MM-DD HH24:MI:SS') as earliest_finish_date,
        to_char(p.latest_finish_date,'YYYY-MM-DD HH24:MI:SS') as latest_finish_date,
        p.actual_hours_completed,
        p.estimated_hours_total
	FROM
	pm_projectsx p
	WHERE
	p.item_id    = :project_item_id and
        p.project_id = :project_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
    </querytext>
  </fullquery>

</queryset>