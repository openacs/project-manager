<?xml version="1.0"?>
<queryset>
  <rdbms><type>oracle</type><version>9.2</version></rdbms>

  <fullquery name="tasks_pagination">
    <querytext>
     select distinct task_id as tasks from (
        SELECT
        ts.task_id
        FROM
        pm_tasks_active ts,
        cr_items i,
        pm_tasks_revisionsx t
          LEFT JOIN pm_task_assignment ta
          ON t.item_id = ta.task_id
            LEFT JOIN persons p
            ON ta.party_id = p.person_id
            LEFT JOIN pm_roles r
            ON ta.role_id = r.role_id,
        cr_items proj,
        cr_folders f,
        pm_projectsx proj_rev
        WHERE
        ts.task_id  = t.item_id and
        i.item_id   = t.item_id and
        t.task_revision_id = i.live_revision and
        t.parent_id = proj.item_id and
        proj.live_revision = proj_rev.revision_id
        and proj.parent_id = f.folder_id
        and f.package_id = :package_id
        [template::list::filter_where_clauses -and -name tasks]
        [template::list::orderby_clause -orderby -name tasks])
    </querytext>
  </fullquery>

</queryset>
