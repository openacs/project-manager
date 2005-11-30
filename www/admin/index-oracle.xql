<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.0</version></rdbms>

<fullquery name="get_root">
    <querytext>
      SELECT pm_project.get_root_folder (:package_id, 'f')
      FROM dual
    </querytext>
</fullquery>

</queryset>
