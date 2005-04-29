<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.0</version></rdbms>

<fullquery name="default_project_roles_query">
    <querytext>
        SELECT  role_id,
                party_id
        FROM    pm_default_roles
    </querytext>
</fullquery>

  <fullquery name="get_root">
    <querytext>
        select pm_project.get_root_folder (:package_id, 'f')
        from dual
    </querytext>
</fullquery>

</queryset>
