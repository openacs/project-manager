<master src="@master;noquote@" />
<property name="portlet_title">#project-manager.Logger#</property>
  <table width="100%">
    <tr>
      <td align="center" colspan="3">
	#project-manager.lt_Priority_task_infopri#<br />
	<if @use_days_p@ true>
	  #project-manager.lt_Days_remaining_task_i#<br />
	</if>
	<else>
	  #project-manager.lt_Hours_remaining_task_#<br />
	</else>
	<if @task_info.slack_time@ nil>
	  #project-manager.Slack_na#
	</if>
	<elseif @task_info.slack_time@ lt 1>
	  #project-manager.Slack# <font color="red">@task_info.slack_time@</font>
	  <br />
	</elseif>
	<else>
	  #project-manager.lt_Slack_task_infoslack_#<br />
	</else>
	#project-manager.lt_Complete_task_infoper#
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td valign="top" colspan="3">
	<form action="task-one" method="post">
	  @variable_widget;noquote@
	  @variable_exports;noquote@
	  @day_widget;noquote@
	  <input type="submit" name="submit" value="#project-manager.View#" />
	</form>
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3">
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
      <td>&nbsp;</td>
    </tr>
  </table>
