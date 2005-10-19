<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#project-manager.Assignees#</property>
<!-- Assignee Portlet Start -->
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-middle">
    <listtemplate name="people">
    </listtemplate>
  </td>
</tr>
<tr>
  <td colspan="2" class="fill-list-bottom">
    <ul>
      <if @roles_listbox_p@>
	<li>@assignee_add_self_widget;noquote@</li>
      </if>
      <if @assigned_p@>
	<li>
	  <a href="@assignee_remove_self_url;noquote@">#project-manager.Remove_myself#</a>
	</li>
      </if>
      <li>
	<a href="@assignee_edit_url;noquote@">#project-manager.Edit_1#</a>
      </li>
      <if @contacts_installed_p@>
      <li>
        <a href="@send_email_url;noquote@">#project-manager.send_mail#</a>
      </li>
      <li>
        <a href="@rate_url;noquote@">#project-manager.Rate_Assignees#</a>
      </li>
      </if>
    </ul>
  </td>
</tr>
</table>
<!-- Assignee Portlet Ends -->
