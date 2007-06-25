<master src="lib/master">

  <link rel="stylesheet" href="/resources/project-manager/style.css" type="text/css" />
  
  <property name="title">#project-manager.Tasks#</property>
  <property name="context">@context@</property>
  <if @passed_project_item_id@ ne 0>
    <property name="project_item_id">@passed_project_item_id@</property>  
  </if>

<table>
<tr valign=top>
<td>
  <include src="/packages/project-manager/lib/tasks" 
	pid_filter="@pid_filter@" 
	status_id="@status_id@" 
	filter_party_id="@filter_party_id@" 
	actions_p="1" 
	fmt="@fmt@"
	instance_id="@instance_id@"
	is_observer_filter="@is_observer_filter@" 
	page_size="@page_size@" 
	page="@page@"
	page_num="@page_num@" 
	base_url="@base_url@" 
	searchterm="@searchterm@" 
	tasks_orderby="@tasks_orderby@" 
	role_id="@role_id@" 
	display_mode="all"
	filter_package_id="@filter_package_id@" 
	subproject_tasks="@subproject_tasks@"
	orderby_p="1"
	/>
</td>
</tr>
</table>


