<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>

  <fullquery name="today">
    <querytext>
      select to_char(now(),'YYYY-MM-DD') from dual
    </querytext>
  </fullquery>

</queryset>
