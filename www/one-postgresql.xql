<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="get_root_folder">
    <querytext>
        select pm_project__get_root_folder (:package_id, 'f')
    </querytext>
  </fullquery>

</queryset>
