<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

   <fullquery name="create_project">     
 
      <querytext>

        select pm_project__get_root_folder(:package_id,'t');
    
      </querytext>
   </fullquery>

   <fullquery name="get_folder_id">
 
      <querytext>

        select pm_project__get_root_folder(:package_id,'f');
    
      </querytext>
   </fullquery>

   <fullquery name="delete_root_folder">
 
      <querytext>

        select content_item__delete(:folder_id);
    
      </querytext>
   </fullquery>

 
</queryset>
