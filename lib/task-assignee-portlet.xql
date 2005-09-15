<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/task-assignee-portlet.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-07-28 -->
<!-- @arch-tag: 12082f1a-f531-4f02-9c0e-b9d7a2d711af -->
<!-- @cvs-id $Id$ -->

<queryset>
    <fullquery name="task_people_query">
    <querytext>
        select
        r.one_line,
        r.role_id,
        r.is_observer_p,
        r.is_lead_p,
	a.party_id
        from 
        pm_task_assignment a,
	persons u,
        pm_roles r
        where 
        a.task_id  = :task_id and
        u.person_id = a.party_id and
        a.role_id  = r.role_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = a.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::orderby_clause -name people -orderby]
    </querytext>
  </fullquery>

    <fullquery name="task_people_group_query">
    <querytext>
        select
        r.one_line,
        r.role_id,
        r.is_observer_p,
        r.is_lead_p,
	a.party_id
        from 
        pm_task_assignment a,
        pm_roles r
        where 
        a.task_id  = :task_id and
        a.role_id  = r.role_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = a.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::orderby_clause -name people -orderby]
    </querytext>
  </fullquery>

</queryset>