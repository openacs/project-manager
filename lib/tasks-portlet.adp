<master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">@task_term@</property>
<!-- Tasks Portlet Start -->
<table width="100%">
<if @instance_html@ not nil>
  <tr>
    <td colspan="2" class="fill-list-middle">@instance_html;noquote@</td>
  </tr>
</if>
<tr>
  <td colspan="2" class="fill-list-middle">
    <include src=/packages/project-manager/lib/tasks project_id="@project_id@" project_item_id="@project_item_id@" return_url="@return_url@" elements="task_item_id status_type title parent_task_id priority slack_time latest_start end_date last_name" display_mode="list" fmt=@fmt@>
  </td>
</tr>
<tr class="list-button-bar">
  <td class="fill-list-bottom" colspan="2">
    <ul>
      <li>
	<form action="task-add-edit" method="post"> 
	  #project-manager.Add# 
	  <input type="hidden" name="project_item_id" value="@project_item_id@" />
	  <input type="hidden" name="return_url"
	    value="@return_url@" />
	  <input type="text"   name="new_tasks" size="3" value="1" />
	  #project-manager.Tasks#
	  <input type="submit" name="submit" value="Go" />
	</form>
      </li>
      <li>
	<form action="process-one" method="post">
	  <input type="hidden" name="project_item_id" value="@project_item_id@" />
	  <input type="hidden" name="return_url" value="@return_url@" />
	  <select name="process_id">
	    @processes_html;noquote@
	  </select>
	  <input type="submit" name="submit" value="Use" />
	</form>
	<if @instance_id@ not nil>
	  <li>
	    <a href="@process_reminder_url@">#project-manager.lt_Send_a_process_remind#</a>
	  </li>
	</if>
    </ul>
  </td>
</tr>
</table>
<!-- Tasks Portlet Ends -->
