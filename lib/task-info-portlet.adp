<master src="@default_layout_url;noquote@" />
<property name="portlet_title">
  <table border="0" width="100%">
    <tr>
      <td>
        <if @task_info.write_p@ eq t>
          <a href="@task_edit_url;noquote@"><img border="0" src="/shared/images/Edit16.gif" alt="Edit" /></a>
        </if>
        <a href="@print_link@"><img border="0" src="resources/print-16.png" alt="Print" /></a>
        <if @task_info.create_p@ eq t>
          <a href="@permissions_url@"><img border="0" src="resources/padlock.gif" alt="Set permissions" /></a>
        </if>
        <if @task_info.priority@ ge @urgency_threshold@>
          <font color="red">
        </if>
        <else>
          <font>
        </else>
        @task_term@ #@task_id@: @task_info.task_title@
      </font>
      </td>
      <td align"right">
	<a href="task-delete?task_item_id=@task_id@">
	  <img border="0" src="/shared/images/Delete16.gif"
            alt="Delete" /></a>
      </td>
    </tr>
  </table>
</property>
<table border="0" cellpadding="3" cellspacing="1" width="100%">
  <tr>
    <td width="70%" valign="top">
      <table border="0" width="100%">
        <if @task_info.end_date@ not nil and @task_info.latest_finish@ ne @task_info.end_date@>
          <tr>
            <td class="subheader" width="40%">#project-manager.Deadline_1#</td>
            <td><b>@task_info.end_date@</b></td>
          </tr>
        </if>
        <tr>
          <td class="subheader" width="40%">#project-manager.Slack_time#</td>
          <td>@task_info.slack_time@</td>
        </tr>
        <tr>
          <td class="subheader" width="40%">#project-manager.Percent_complete#</td>
          <td>@task_info.percent_complete@%</td>
        </tr>
        <tr>
          <td class="subheader" width="40%">#project-manager.Estimated_hours_work#</td>
          <td>@task_info.estimated_hours_work@</td>
        </tr>
        <if @process_html@ not nil>
          <tr>
            <td class="subheader" width="40%">#project-manager.Process_status#</td>
            <td>@process_html;noquote@</td>
          </tr>
        </if>
        <tr>
          <td class="subheader" width="40%">#project-manager.Priority#</td>
          <td>@task_info.priority@</td>
        </tr>
        <tr>
          <td class="subheader" width="40%">#project-manager.Actions#</td>
          <td><a href="task-revisions?task_id=@task_id@">#project-manager.View_task_changes#</a></td>
        </tr>
      </table>
    </td>
    <td width="30%" valign="top">
      <table border="0" width="100%">
        <if @task_info.earliest_start@ not nil>
          <tr>
            <td class="subheader" width="60%">#project-manager.Earliest_start#</td>
            <td>@task_info.earliest_start@&nbsp;</td>
          </tr>
        </if>
        
        <if @task_info.earliest_finish@ not nil>
          <tr>
            <td class="subheader" width="60%">#project-manager.Earliest_finish#</td>
            <td>@task_info.earliest_finish@</td>
          </tr>
        </if>
	
        <if @task_info.latest_start@ not nil>
          <tr>
            <td class="subheader" width="60%">#project-manager.Latest_start#</td>
            <td>@task_info.latest_start@</td>
          </tr>
        </if>
        
        <if @task_info.latest_finish@ not nil>
          <tr>
            <td class="subheader" width="40%">#project-manager.Latest_finish#</td>
            <td><b>@task_info.latest_finish@</b></td>
          </tr>
        </if>
    </td>
  </tr>
  </table>
  </td>
</tr>
  <tr>
        <td>&nbsp;</td>
  </tr>
    <td class="subheader" colspan="2">#project-manager.Description#</td>
  </tr>
  <tr>
    <td class="list-bg" colspan="2">@task_info.description;noquote@</td>
  </tr>
  <multiple name="dynamic_attributes">
    <tr>
      <td class="subheader" colspan="2">@dynamic_attributes.name@</td>
    </tr>
    <tr>
      <td class="list-bg" colspan="2">@dynamic_attributes.value@</td>
    </tr>
  </multiple>
  <tr>
    <td class="list-bg" align="left" colspan="2">- @task_info.creation_user@</td>
  </tr>
  <tr>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <tr>
      <td class="subheader" colspan="2">#project-manager.Comments#</th>
    </tr>
    <tr>
      <td class="list-bg" colspan="2">@comments;noquote@
	<P />
	@comments_link;noquote@
      </td>
    </tr>
</table>
   
