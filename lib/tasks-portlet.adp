<master src="@default_layout_url;noquote@" />
<property name="portlet_title">@task_term@</property>
<!-- Tasks Portlet Start -->
<table width="100%">
<if @instance_html@ not nil>
  <tr>
    <td colspan="2" class="fill-list-middle">
        <form action="one" method="get">
        @instance_html;noquote@
        <if @instance_id@ gt 0>
          <a href="@process_reminder_url@">#project-manager.lt_Send_a_process_remind#</a>
        </if>
        </form>
      </td>
    </tr>
  </if>
<tr>
  <td colspan="2" class="fill-list-middle">
    <include src=/packages/project-manager/lib/tasks project_id="@project_id@"
    pid_filter="@project_item_id@" return_url="@return_url@"
    elements="@elements@" display_mode="list" fmt=@fmt@
    instance_id="@instance_id@" status_id="1" page="@page@" orderby_p="@orderby_p@"
    page_size="@page_size@" tasks_orderby="@tasks_orderby@">
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
      </ul>
  </td>
</tr>
</table>
<!-- Tasks Portlet Ends -->
