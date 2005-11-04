<?xml varsion="1.0"?>
<queryset>

<fullquery name="check_assign">
    <querytext>
	select 
		1
	from
		pm_task_assignment
	where
		task_id = :task
		and role_id = :role_id
		and party_id = :user_id
    </querytext>
</fullquery>

<fullquery name="assign_tasks">
    <querytext>
        insert into pm_task_assignment (task_id, role_id, party_id)
	values (:task, :role_id, :user_id)
    </querytext>
</fullquery>

</queryset>
