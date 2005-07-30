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
  <include src="/packages/project-manager/lib/tasks" project_item_id="@project_item_id@" status_id="@status_id@" party_id="@party_id@" actions_p="1" fmt=@fmt@>
</td>
</tr>
</table>


