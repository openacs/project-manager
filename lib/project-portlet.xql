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
        p.item_id,
	p.project_id,
	p.title as project_name,
	p.project_code,
	p.goal,
	p.description,
        p.mime_type, 
	to_char(p.planned_start_date,'YYYY-MM-DD HH24:MI') as planned_start_date,
	to_char(p.planned_end_date,'YYYY-MM-DD HH24:MI') as planned_end_date,
	p.ongoing_p,
        i.live_revision,
        to_char(p.estimated_finish_date,'YYYY-MM-DD HH24:MI') as estimated_finish_date,
        to_char(p.earliest_finish_date,'YYYY-MM-DD HH24:MI') as earliest_finish_date,
        to_char(p.latest_finish_date,'YYYY-MM-DD HH24:MI') as latest_finish_date,
        p.actual_hours_completed,
        p.estimated_hours_total,
        p.parent_id,
        s.status_type,
        acs_permission__permission_p (:project_id,:user_id,'write') as write_p,
        acs_permission__permission_p (:project_id,:user_id,'create') as create_p
	FROM
	pm_projectsx p, 
        cr_items i,
        pm_project_status s
	WHERE
	p.item_id    = :project_item_id and
        p.project_id = :project_id and
        p.item_id    =  i.item_id and
        p.status_id  =  s.status_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
    </querytext>
  </fullquery>

  <fullquery name="forum_package_id">
    <querytext>
	select package_id as forum_package_id
	from acs_objects
	where object_id = :forum_id
    </querytext>
  </fullquery>

  <fullquery name="folder_package_id">
    <querytext>
	select package_id as folder_package_id
	from acs_objects
	where object_id = :folder_id
    </querytext>
  </fullquery>

</queryset>
