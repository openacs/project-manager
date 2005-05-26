<master src="lib/master">

  <link rel="stylesheet" href="style.css" type="text/css" />
    
  <property name="title">#project-manager.Projects#</property>
  <property name="context">@context;noquote@</property>

  <include src=/packages/project-manager/lib/projects orderby=@orderby;noquote@ status_id=@status_id@ searchterm=@searchterm@ assignee_id=@assignee_id@ category_id=@pass_cat@ elements="customer_name category_id earliest_finish_date latest_finish_date actual_hours_completed" package_id=@package_id@ actions_p="1" bulk_p="1">



