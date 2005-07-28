<master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">#project-manager.Assignees#</property>
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
    </ul>
  </td>
</tr>
</table>
