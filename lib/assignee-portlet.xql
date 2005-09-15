<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/people.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-01 -->
<!-- @arch-tag: cb6d4744-1947-49b7-a3ab-a9f25a383956 -->
<!-- @cvs-id $Id$ -->

<queryset>

    <fullquery name="project_people_query">
    <querytext>
        SELECT
        a.project_id,
        r.one_line as role_name,
        p.first_names || ' ' || p.last_name as user_name,
        a.party_id,
        r.is_lead_p
        FROM 
        pm_project_assignment a,
        pm_roles r,
	persons p
        WHERE
        a.role_id = r.role_id and
	a.party_id = p.person_id and
        project_id = :project_item_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :project_item_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        ORDER BY
        r.role_id, p.first_names, p.last_name
    </querytext>
  </fullquery>

    <fullquery name="project_people_groups_query">
    <querytext>
        SELECT
        a.project_id,
        r.one_line as role_name,
        a.party_id,
        r.is_lead_p
        FROM 
        pm_project_assignment a,
        pm_roles r
        WHERE
        a.role_id = r.role_id and
        project_id = :project_item_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :project_item_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        ORDER BY
        r.role_id
    </querytext>
  </fullquery>

</queryset>