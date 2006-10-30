<master src="@default_layout_url;noquote@" />
<property name="portlet_title">
  <table border="0" width="100%">
    <tr>
      <td>
        <if @task_info.write_p@ eq t>
          <a href="@task_edit_url;noquote@"><img border="0" src="/resources/acs-subsite/Edit16.gif" alt="Edit" /></a>
        </if>
        <a href="@print_link@"><img border="0" src="/resources/project-manager/print-16.png" alt="Print" /></a>
        <if @task_info.create_p@ eq t>
          <a href="@permissions_url@"><img border="0" src="/resources/project-manager/padlock.gif" alt="Set permissions" /></a>
        </if>
        <if @task_info.priority@ ge @urgency_threshold@>
          <font color="red">
        </if>
        <else>
          <font>
        </else>
        @project_title@: @task_info.task_title@ (#@task_id@)
      </font>
      </td>
      <td align"right">
	<a href="task-delete?task_item_id=@task_id@">
	  <img border="0" src="/resources/acs-subsite/Delete16.gif"
            alt="Delete" /></a>
      </td>
    </tr>
  </table>
</property>
<table border="0" cellpadding="1" cellspacing="1" width="100%">
  <tr>
    <td class="list-bg" colspan="2">@task_info.description;noquote@</td>
  </tr>
  <tr>
    <td class="list-bg" align="right" colspan="2">- @task_info.creation_user@</td>
  </tr>
</table>
<p>
      <table border="0" width="100%">
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
	  <multiple name="dynamic_attributes">
	      <tr>  
	        <td class="subheader" colspan="2">@dynamic_attributes.name@</td>
                <td class="list-bg" colspan="2">@dynamic_attributes.value@</td>
             </tr>
	  </multiple>
        <tr>
          <td class="subheader" width="40%">#project-manager.Actions#</td>
	  </tr>
	  <tr>
          <td><ul><li><a href="task-revisions?task_id=@task_id@">#project-manager.View_task_changes#</a></li></ul></td>
        </tr>
      </table>
<p>
<table>
    <tr>
      <td class="subheader" colspan="2">#project-manager.Comments#</th>
    </tr>
    <tr>
      <td class="list-bg" colspan="2">@comments;noquote@
	<P />
	<ul><li>@comments_link;noquote@</li></ul>
      </td>
    </tr>
</table>
   
