<?xml version="1.0"?>
<queryset>

<rdbms><type>oracle</type><version>9.2</version></rdbms>

  <fullquery name="get_root_folder">
    <querytext>
        begin
            :1 := pm_project.get_root_folder (:package_id, 'f');
        end;
    </querytext>
  </fullquery>

</queryset>
