<?xml version="1.0"?>
<queryset>
  <fullquery name="project_query">
    <querytext>
        SELECT  p.item_id as project_item_id,
                p.title as project_name,
	        p.description
        FROM    pm_projectsx p
        WHERE   p.project_id = :old_project_id 
    </querytext>
  </fullquery>

  <fullquery name="update_project">
    <querytext>
        UPDATE  pm_projects set
        WHERE
        project_id = :project_id
    </querytext>
  </fullquery>

</queryset>
