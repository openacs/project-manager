<if @project_id_p@>
    <include src=@template_src@  project_id=@project_id@  dform=@dform@ project_revision_id=@project_revision_id@ project_item_id=@project_item_id@  project_name=@project_name@ project_code=@project_code@ parent_id=@parent_id@  goal=@goal@  description=@description@  customer_id=@customer_id@  planned_start_date=@planned_start_date@  planned_end_date=@planned_end_date@  deadline_scheduling=@deadline_scheduling@  ongoing_p=@ongoing_p@  status_id=@status_id@  extra_data=@extra_data@>
</if>
<else>
    <include src=@template_src@ dform=@dform@ project_revision_id=@project_revision_id@ project_item_id=@project_item_id@  project_name=@project_name@ project_code=@project_code@ parent_id=@parent_id@  goal=@goal@  description=@description@  customer_id=@customer_id@  planned_start_date=@planned_start_date@  planned_end_date=@planned_end_date@  deadline_scheduling=@deadline_scheduling@  ongoing_p=@ongoing_p@  status_id=@status_id@  extra_data=@extra_data@>
</else>