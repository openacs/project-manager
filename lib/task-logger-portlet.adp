<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#project-manager.Logger#</property>
  <table width="100%" border="0">
    <tr> 
      <td valign="top">
	<form action="task-one" method="post">
	  @variable_widget;noquote@
	  @variable_exports;noquote@
	  @day_widget;noquote@
	  <input type="submit" name="submit" value="#project-manager.View#" />
	</form>
      </td>
  </tr>
    <tr>
      <td>
	<include
	  src="/packages/logger/lib/entries"
	  project_id="@logger_project@"
	  variable_id="@logger_variable_id@"
	  filters_p="f"
	  pm_project_id="@project_item_id@"
	  pm_task_id="@task_info.item_id@"
	  start_date="@then_ansi@"
	  end_date="@nextyear_ansi@"
	  url="@logger_url;noquote@"
	  add_link="@log_url;noquote@"
	  show_orderby_p="f"
	  project_manager_url="@package_url;noquote@"
	  return_url="@return_url;noquote@" />
      </td>
  </tr>
  </table>
