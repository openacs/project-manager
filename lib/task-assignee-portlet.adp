<master src="@default_layout_url@" />
<property name="portlet_title">#project-manager.Assignees#</property>
<table width="100%">
  <tr>
    <td colspan="2">
      <listtemplate name="people">
      </listtemplate>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <ul>
	<li>@assignee_add_self_widget;noquote@</li>
	<if @assigned_p@>
	  <li>
	    <a href="@assignee_remove_self_url;noquote@">#project-manager.Remove_myself#</a>
	  </li>
	</if>
      </ul>
    </td>
  </tr>
</table>
