<?xml version="1.0"?>

<queryset>

<fullquery name="get_user_fullname">
    <querytext>
	select
		first_names ||' '|| last_name as fullname
	from
		persons
	where
		person_id = :search_user_id
    </querytext>
</fullquery>

</queryset>