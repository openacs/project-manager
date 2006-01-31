<?xml version="1.0"?>

<queryset>
  <fullquery name="update_album">
    <querytext>
        update pm_projects 
        set album_id = :album 
        where project_id = :project_id
    </querytext>
  </fullquery>

</queryset>
