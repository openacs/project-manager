<master src="lib/master">

  <link rel="stylesheet" href="style.css" type="text/css" />
    
<property name="title">#project-manager.Projects#</property>
<property name="context">@context;noquote@</property>

<include src="/packages/project-manager/lib/projects" 
	orderby="@orderby;noquote@" 
	pm_status_id="@pm_status_id@" 
	searchterm="@searchterm@" 
	assignee_id="@assignee_id@" 
	pm_contact_id="@pm_contact_id@" 
	pm_etat_id="@pm_etat_id@" 
	category_id="@pass_cat@" 
	elements="project_code customer_name contact_id etat_id category_id start_date planned_end_date status_id" 
	package_id=@package_id@ 
	actions_p="1" 
	bulk_p="1" 
	fmt="@fmt@" 
	date_range="@date_range@" 
	user_space_p="@user_space_p@" 
	is_observer_p="@is_observer_p@" 
	hidden_vars="@hidden_vars;noquote@" 
	previous_status_f="@previous_status_f@"
	current_package_f="@current_package_f@"
	page_size="@page_size@" 
	page="@page@"
	page_num="@page_num@" 
	subprojects_p="@subprojects_p@"
	/>

