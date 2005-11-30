<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

  <fullquery name="get_root">
    <querytext>
        select pm_project__get_root_folder (:package_id, 'f')
        from dual
    </querytext>
</fullquery>

</queryset>
