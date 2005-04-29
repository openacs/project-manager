<?xml version="1.0"?>
<queryset>
  <rdbms><type>oracle</type><version>8.0</version></rdbms>
  <fullquery name="roles_and_abbrevs">
    <querytext>
    SELECT one_line as role,
           substr(one_line,1,1) as abbreviation
    FROM   pm_roles
    </querytext>
  </fullquery>

</queryset>
