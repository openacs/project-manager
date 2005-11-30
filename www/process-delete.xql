<?xml version="1.0"?>
<queryset>

  <fullquery name="get_name">
    <querytext>
      SELECT one_line, 
             description 
      FROM   pm_process 
      WHERE  process_id = :process_id
    </querytext>
  </fullquery>

</queryset>
