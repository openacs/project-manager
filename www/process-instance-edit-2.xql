<?xml version="1.0"?>
<!--  -->
<!-- @author  (jader-ibr@bread.com) -->
<!-- @creation-date 2004-11-05 -->
<!-- @arch-tag: 9da693b9-6933-47e0-89da-103a32ab1c4c -->
<!-- @cvs-id $Id$ -->

<queryset>

  <fullquery name="change_process_instance">
    <querytext>
      UPDATE
      pm_process_instance 
      SET
      name = :my_name
      WHERE
      instance_id = :instance_id
    </querytext>
  </fullquery>
  
</queryset>
