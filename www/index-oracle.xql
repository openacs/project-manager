<?xml version="1.0"?>
<queryset>

<rdbms><type>oracle</type><version>9.2</version></rdbms>

  <fullquery name="get_root">
    <querytext>
        select pm_project.get_root_folder (:package_id, 'f')
        from dual
    </querytext>
</fullquery>


</queryset>
