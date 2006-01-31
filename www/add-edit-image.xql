<?xml version="1.0"?>

<queryset>
  <fullquery name="get_album_id">
    <querytext>
        select album_id 
        from pm_projectsx 
        where project_id = :project_id
    </querytext>
  </fullquery>

  <fullquery name="update_image">
    <querytext>
        update pm_projects 
        set image_id = :image 
        where project_id = :project_id
    </querytext>
  </fullquery>

</queryset>
