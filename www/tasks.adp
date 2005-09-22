<master src="lib/master">

  <link rel="stylesheet" href="style.css" type="text/css" />
  
  <property name="title">#project-manager.Tasks#</property>
  <property name="context">@context@</property>
  <if @passed_project_item_id@ ne 0>
    <property name="project_item_id">@passed_project_item_id@</property>  
  </if>

<table>
<tr valign=top>
<td>
  <include src="/packages/project-manager/lib/tasks" project_item_id="@project_item_id@" status_id="@status_id@" party_id="@party_id@" actions_p="1" fmt=@fmt@ instance_id=@instance_id@ is_observer_p=@is_observer_p@ page_size="@page_size@" page="@page@" page_num="@page_num@" base_url="@base_url@" searchterm="@searchterm@" orderby="@orderby@" role_id="@role_id@" filter_package_id="@filter_package_id@">
</td>
</tr>
</table>


