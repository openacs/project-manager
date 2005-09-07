<master src="lib/master">

  <link rel="stylesheet" href="style.css" type="text/css" />
    
<property name="title">#project-manager.Projects#</property>
<property name="context">@context;noquote@</property>

<include src="/packages/project-manager/lib/projects" orderby=@orderby;noquote@ status_id=@status_id@ searchterm=@searchterm@ assignee_id=@assignee_id@ category_id=@pass_cat@ elements="project_code customer_name category_id creation_date start_date planned_end_date actual_hours_completed status_id" package_id=@package_id@ actions_p="1" bulk_p="1" fmt=@fmt@ date_range=@date_range@ user_space_p=@user_space_p@ is_observer_p=@is_observer_p@ hidden_vars=@hidden_vars;noquote@>

