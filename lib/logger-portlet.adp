<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#project-manager.Logger#</property>
<!-- Logger Portlet Start -->
<table width="100%">
<tr class="list-button-bar">
  <td class="fill-list-middle" valign="top">
    <form action="one" method="post">
      @variable_widget;noquote@
      @variable_exports;noquote@
      @day_widget;noquote@
      <input type="submit" name="submit" value="#acs-kernel.common_View#" />
    </form>
  </td>
  <td align=right>#project-manager.Hours_completed#: @hours_sum@</td>
</tr>
<tr>
  <td colspan="2" class="fill-list-bottom">
    <include
      src="/packages/logger/lib/entries"
      project_ids="@logger_projects@"
      variable_id="@logger_variable_id;noquote@"
      filters_p="f"
      show_tasks_p="1"
      pm_project_id="@project_item_id;noquote@"
      start_date="@then_ansi;noquote@"
      end_date="@today_ansi;noquote@"
      url="@logger_url;noquote@"
      add_link="@log_url;noquote@"
      project_manager_url="@pm_url;noquote@"
      return_url="@return_url;noquote@" />
  </td>
</tr>
</table>
<!-- Logger Portlet Stops -->
