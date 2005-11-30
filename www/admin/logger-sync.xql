<queryset>

  <fullquery name="get_projects_not_already_linked">
    <querytext>
        SELECT
        p.title as project_name,
        p.description,
        p.creation_user,
        p.item_id as project_item_id,
        p.status_id,
        p.customer_id as organization_id,
        p.logger_project
        FROM
        pm_projectsx p,
        cr_items i
        WHERE
        i.item_id = p.item_id and
        i.live_revision = p.revision_id
    </querytext>
  </fullquery>

  <fullquery name="already_exists_p">
    <querytext>
        SELECT count(*) 
        FROM logger_project_pkg_map 
        WHERE project_id = :logger_project 
        AND package_id = :this_package_id
    </querytext>
  </fullquery>

</queryset>
