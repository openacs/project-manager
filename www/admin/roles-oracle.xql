<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.0</version></rdbms>

<fullquery name="roles_query">
    <querytext>
        SELECT role_id,
               one_line,
               description,
               is_observer_p,
               sort_order
        FROM   pm_roles
    </querytext>
</fullquery>

  <fullquery name="get_root">
    <querytext>
        select pm_project.get_root_folder (:package_id, 'f')
        from dual
    </querytext>
</fullquery>

</queryset>
