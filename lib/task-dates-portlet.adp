<master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">#project-manager.Dates#</property>
<table>
  <tr>
    <td colspan="2" class="list-bottom-bg">
      <table border="0" class="list" width="100%">
	<tr>
	  <td class="highlight">#project-manager.Earliest_start#</td>
	  <td>@task_info.earliest_start@&nbsp;</td>
	</tr>
	
	<tr>
	  <td class="highlight">#project-manager.Earliest_finish#</td>
	  <td>@task_info.earliest_finish@</td>
	</tr>
	
	<tr>
	  <td class="highlight">#project-manager.Latest_start#</td>
	  <td>@task_info.latest_start@</td>
	</tr>
	
	<tr>
	  <td class="highlight">#project-manager.Latest_finish#</td>
	  <td><b>@task_info.latest_finish@</b></td>
	</tr>

	<if @task_info.latest_finish@ ne @task_info.end_date@>
	  <tr>
	    <td class="highlight">#project-manager.Deadline_1#</td>
	    <td><b>@task_info.end_date@</b></td>
	  </tr>
	</if>
	
      </table>
    </td>
    <td class="list-right-bg">&nbsp;</td>
  </tr>
</table>
