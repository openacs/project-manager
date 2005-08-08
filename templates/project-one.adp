<master src="../www/lib/master" />
<if @project.status_type@ eq c>
  <property name="title">@my_title;noquote@ -- #project-manager.Closed#</property>
</if>
<else>
  <property name="title">@my_title;noquote@</property>
</else>
<property name="context">@context;noquote@</property>
<property name="project_item_id">@project_item_id@</property>
<if @project.live_revision@ ne @project.project_id@>
  <h4>#project-manager.lt_not_current_set_live#</h4>
</if>
<include
  src="/packages/project-manager/lib/project-portlet"
  project_id="@project_id@"
  project_item_id="@project_item_id@" 
  fmt=@fmt@ />
<p />
<include
  src="/packages/project-manager/lib/date-portlet"
  project_id="@project_id@"
  project_item_id="@project_item_id@" />
<p />
<include
  src=/packages/project-manager/lib/assignee-portlet
  project_id="@project_id@"
  project_item_id="@project_item_id@"
  return_url="@return_url@" />
  <p />
  <include
    src="/packages/project-manager/lib/categories-portlet"
    item_id="@project_id@" />
  <p />
  <if @use_subprojects_p@>
    <include
      src="/packages/project-manager/lib/subprojects"
      project_id="@project_id@"
      project_item_id="@project_item_id@" 
      base_url=@package_url@
      />
    <p />
  </if>
  <include
    src="/packages/project-manager/lib/comments-portlet"
    project_id="@project_id@"
    project_item_id="@project_item_id@"
    return_url="@return_url@" />
</td>
  <td valign="top">
    <include
      src="/packages/project-manager/lib/tasks-portlet"
      project_id="@project_id@"
      project_item_id="@project_item_id@"
      return_url="@return_url@"
      instance_id="@instance_id@" 
      fmt=@fmt@ 
	/>
    <p />
    <include
      src="/packages/project-manager/lib/logger-portlet"
      project_item_id="@project_item_id@"
      return_url="@return_url@"
      master="@portlet_master@"
      logger_project="@project.logger_project@"
      logger_days="@logger_days@"
      return_url="@return_url;noquote@"
      pm_url="@package_url;noquote@" />
    <p />
    <if @use_project_customizations_p@>
      <p />
      <include
	src="/packages/project-manager/lib/assignee-portlet"
	project_id="@project_id@"
	project_item_id="@project_item_id@"
	return_url="@return_url@" />
      <p />
      <include
	src="/packages/project-manager/lib/categories-portlet"
	item_id="@project_id@" />
      <p />
      <if @use_subprojects_p@>
	<include
	  src="/packages/project-manager/lib/subprojects"
	  project_id="@project_id@"
	  project_item_id="@project_item_id@" />
	<p />
      </if>
      <include
	src="/packages/project-manager/lib/comments-portlet"
	project_id="@project_id@"
	project_item_id="@project_item_id@"
	return_url="@return_url@" />
    </td>
    <td width="50%" valign="top">
      <include
	src="/packages/project-manager/lib/tasks-portlet"
	project_id="@project_id@"
	project_item_id="@project_item_id@"
	return_url="@return_url@"
	instance_id="@instance_id@" />
      <p />
      <include
	src="/packages/project-manager/lib/logger-portlet"
	project_item_id="@project_item_id@"
	return_url="@return_url@"
	master="@portlet_master@"
	logger_project="@project.logger_project@"
	logger_days="@logger_days@"
	return_url="@return_url;noquote@"
	pm_url="@package_url;noquote@" />
      <p />
      <if @use_project_customizations_p@>
	<p />
	<include
	  src="/packages/project-manager/lib/customization-portlet"
	  project_id="@project_id@"
	  project_item_id="@project_item_id@" />
      </if>
      <p />
      <if @forum_id@ ge 0>
	<include
	  src="/packages/project-manager/lib/forums-portlet"
	  forum_id="@forum_id@" />
      </if>
      <p />
      <if @folder_id@ ge 0>
	<include
	  src="/packages/project-manager/lib/fs-portlet"
	  folder_id="@folder_id@" />
      </if>
    </td>
  </tr>
</table>