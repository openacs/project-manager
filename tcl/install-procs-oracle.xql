<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

   <fullquery name="create_project">     
      <querytext>
        select pm_project.get_root_folder(:package_id,'t') from dual
      </querytext>
   </fullquery>

   <fullquery name="get_folder_id">
 
      <querytext>
        select pm_project.get_root_folder(:package_id,'f') from dual
      </querytext>
   </fullquery>

   <fullquery name="delete_root_folder">
       <querytext>
        exec content_item.del(:folder_id)
      </querytext>
   </fullquery>

 
</queryset>
