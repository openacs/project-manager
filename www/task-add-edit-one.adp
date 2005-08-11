<if @exist_task_p@>
   <if @exist_assignee_p@>	
       <include src="@template_src@" task_item_id=@task_item_id@ dform=@dform@ project_item_id=@project_item_id@ process_id=@process_id@ process_task_id=@process_task_id@ return_url=@return_url@ &assignee=assignee>
   </if>
   <else>
       <include src="@template_src@" task_item_id=@task_item_id@ dform=@dform@ project_item_id=@project_item_id@ process_id=@process_id@ process_task_id=@process_task_id@ return_url=@return_url@>
   </else>
</if>
<else>
   <if @exist_assignee_p@>	
       <include src="@template_src@" dform=@dform@ project_item_id=@project_item_id@ process_id=@process_id@ process_task_id=@process_task_id@ return_url=@return_url@ &assignee=assignee>
   </if>
   <else>
       <include src="@template_src@" dform=@dform@ project_item_id=@project_item_id@ process_id=@process_id@ process_task_id=@process_task_id@ return_url=@return_url@>
   </else>
</else>