<?xml version="1.0"?>
<queryset>

  <fullquery name="task_query">
    <querytext>
        SELECT
        t.item_id,
        t.parent_id as project_item_id,
        t.title as task_title,
        t.revision_id,
        t.description,
        t.mime_type,
        to_char(t.earliest_start,'YYYY-MM-DD HH24:MI:SS') as earliest_start,
        to_char(t.earliest_start,'J') as earliest_start_j,
        to_char(t.earliest_finish,'YYYY-MM-DD HH24:MI:SS') as earliest_finish,
        to_char(t.latest_start,'YYYY-MM-DD HH24:MI:SS') as latest_start,
        to_char(t.latest_start,'J') as latest_start_j,
        to_char(t.latest_finish,'YYYY-MM-DD HH24:MI:SS') as latest_finish,
        to_char(t.end_date,'YYYY-MM-DD HH24:MI:SS') as end_date,
        to_char(current_date,'J') as today_j,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        t.percent_complete,
	t.priority,
        t.dform,
        i.live_revision,
        p.first_names || ' ' || p.last_name as creation_user,
        proj_rev.title as project_name,
        a.process_instance,
        acs_permission__permission_p (:task_id,:user_id,'write') as write_p,
        acs_permission__permission_p (:task_id,:user_id,'create') as create_p
        FROM
        pm_tasks_revisionsx t,
        cr_items i,
        persons p,
        cr_items proj,
        cr_revisions proj_rev,
        pm_tasks_active a
        WHERE
        t.item_id = :task_id and
        t.revision_id = :task_revision_id and
        t.item_id = i.item_id and
        t.creation_user = p.person_id and
        t.parent_id = proj.item_id and
        proj.live_revision = proj_rev.revision_id and
        t.item_id = a.task_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = a.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
    </querytext>
  </fullquery>

  <fullquery name="task_people_query">
    <querytext>
        select
        r.one_line,
        u.first_names || ' ' || u.last_name as user_info,
        r.role_id,
        r.is_observer_p,
        r.is_lead_p
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

</queryset>
