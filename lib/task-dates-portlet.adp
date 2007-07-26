<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#project-manager.Dates#</property>
<table width="100%">
  <tr>
    <td colspan="2">
      <table border="0" width="100%">
        <if @task_info.earliest_start@ not nil>
	  <tr>
	    <td class="highlight">#project-manager.Earliest_start#</td>
	    <td>@task_info.earliest_start@&nbsp;</td>
	  </tr>
        </if>
	
        <if @task_info.earliest_finish@ not nil>
	  <tr>
	    <td class="highlight">#project-manager.Earliest_finish#</td>
	    <td>@task_info.earliest_finish@</td>
	  </tr>
        </if>
	
        <if @task_info.latest_start@ not nil>
	  <tr>
	    <td class="highlight">#project-manager.Latest_start#</td>
	    <td>@task_info.latest_start@</td>
	  </tr>
        </if>
	
        <if @task_info.latest_finish@ not nil>
	  <tr>
	    <td class="highlight">#project-manager.Latest_finish#</td>
	    <td><b>@task_info.latest_finish@</b></td>
	  </tr>
        </if>

        <if @task_info.end_date@ not nil and @task_info.latest_finish@ ne @task_info.end_date@>
	  <tr>
	    <td class="highlight">#project-manager.Deadline_1#</td>
	    <td><b>@task_info.end_date@</b></td>
	  </tr>
	</if>

        <if @task_info.slack_time@ not nil>
        <tr>
          <td class="subheader" width="40%">#project-manager.Slack_time#</td>
          <td>@task_info.slack_time@</td>
        </tr>
       </if>
        <if @task_info.percent_complete@ not nil>
        <tr>
          <td class="subheader" width="40%">#project-manager.Percent_complete#</td>
          <td>@task_info.percent_complete@%</td>
        </tr>
	</if>
        <if @task_info.hours_remaining@ not nil>
        <tr>
          <td class="subheader" width="40%">#project-manager.Estimated_hours_work#</td>
          <td>@task_info.hours_remaining@ (@task_info.estimated_hours_work_min@ - @task_info.estimated_hours_work_max@)</td>
        </tr>
	</if>
	<if @task_info.priority@ not nil>
        <tr>
          <td class="subheader" width="40%">#project-manager.Priority#</td>
          <td>@task_info.priority@ </td>
        </tr>
	</if> 
      </table>
    </td>
  </tr>
</table>
