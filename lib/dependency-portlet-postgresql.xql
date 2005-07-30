<?xml version="1.0"?>
<queryset>

  <fullquery name="depend_on_other">
    <querytext>
        SELECT
        t.title as task_title,
        to_char(t.end_date,'YYYY-MM-DD HH24:MI') as end_date,
        t.percent_complete,
        i.live_revision,
        d.parent_task_id,
        d.dependency_type,
        t.item_id as d_task_id
        FROM
        pm_tasks_revisionsx t, cr_items i, pm_task_dependency d
        WHERE
        d.task_id        = :task_id and
        d.parent_task_id = t.item_id and 
        t.revision_id    = i.live_revision and
        t.item_id        = i.item_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = d.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::orderby_clause -name dependency -orderby]
    </querytext>
  </fullquery>

  <fullquery name="depend_on_this_task">
    <querytext>
        SELECT
        t.title as task_title,
        to_char(t.end_date,'YYYY-MM-DD HH24:MI') as end_date,
        t.percent_complete,
        i.live_revision,
        d.parent_task_id,
        d.dependency_type,
        d.task_id as d_task_id
        FROM
        pm_tasks_revisionsx t, cr_items i, pm_task_dependency d
        WHERE
        d.task_id        = t.item_id and
        d.parent_task_id = :task_id and 
        t.revision_id    = i.live_revision and
        t.item_id        = i.item_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = d.task_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        [template::list::orderby_clause -name dependency -orderby]
    </querytext>
  </fullquery>

</queryset>
