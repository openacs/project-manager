<?xml version="1.0"?>
<queryset>

  <fullquery name="update_parent_id">
    <querytext>
	    update cr_items
	    set parent_id = :parent_id
	    where item_id = :project_item_id
    </querytext>
  </fullquery>

</queryset>
