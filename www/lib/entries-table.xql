<?xml version="1.0"?>

<queryset>

  <fullquery name="select_variable_info">
    <querytext>
	    select name,
	           unit,
	           type
	    from   logger_variables
	    where  variable_id = :selected_variable_id
    </querytext>
  </fullquery>

</queryset>
