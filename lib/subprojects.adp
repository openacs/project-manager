<master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">#project-manager.Subprojects#</property>
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-middle">
    <listtemplate name="subproject">
    </listtemplate>
  </td>
  <td class="fill-list-right2">&nbsp;</td>
</tr>
<tr class="list-button-bar">
  <td class="fill-list-bottom" colspan="2">
    <ul>
      <li>
	<a href="add-edit?parent_id=@project_item_id@" class="list-button"
	  title="Add a subproject to this project">#project-manager.Add__subproject#</a>
      </li>
    </ul>
  </td>
  <td class="fill-list-right2">&nbsp;</td>
</tr>
</table>