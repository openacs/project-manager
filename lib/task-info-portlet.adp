<master src="@default_layout_url;noquote@" />
<property name="portlet_title">
  <table width="100%">
    <tr>
      <if @task_info.percent_complete@ ge 100>
	<th class="shaded">
      </if>
      <else>
	<th>
      </else>
      <if @task_info.write_p@ eq t>
	<a href="@task_edit_url;noquote@">
	  <img border="0" src="/shared/images/Edit16.gif"
	    alt="Edit" />
	</a>
      </if>
      <a href="@print_link@">
	<img border="0" src="resources/print-16.png"
	  alt="Print" />
      </a>
      <if @task_info.create_p@ eq t>
	<a href="@permissions_url@">
	  <img border="0" src="resources/padlock.gif" alt="Set permissions" />
	</img>
	</a>
      </if>
      <if @task_info.priority@ ge @urgency_threshold@>
	<font color="red">
      </if>
      <else>
	<font>
      </else>
      @task_term@ #@task_id@: @task_info.task_title@
    </font>
    </th>
      <th align="left">
	<a href="task-delete?task_item_id=@task_id@">
	  <img border="0" src="/shared/images/Delete16.gif" />
	</a>
      </th>
    </tr>
  </table>
</property>
<table border="0" cellpadding="3" cellspacing="1" width="100%">
  <tr>
    <td class="subheader">#project-manager.Description#</td>
  </tr>
  <tr>
    <td class="list-bg">@task_info.description;noquote@</td>
  </tr>
  <multiple name="dynamic_attributes">
    <tr>
      <td class="subheader">@dynamic_attributes.name@</td>
    </tr>
    <tr>
      <td class="list-bg">@dynamic_attributes.value@</td>
    </tr>
  </multiple>
  <tr>
    <td class="list-bg" align="right">-- @task_info.creation_user@</td>
  </tr>
  <tr>
    <tr>
      <td class="subheader">#project-manager.Comments#</th>
    </tr>
    <tr>
      <td class="list-bg">@comments;noquote@
	<P />
	@comments_link;noquote@
      </td>
    </tr>
    <tr>
      <td class="subheader">#project-manager.Actions#</td>
    </tr>
    <tr>
      <td class="list-bottom-bg">
	<ul>
	  <li>
	    <a href="task-revisions?task_id=@task_id@">#project-manager.View_task_changes#</a>
	  </li>
	</ul>
      </td>
    </tr>
</table>
   