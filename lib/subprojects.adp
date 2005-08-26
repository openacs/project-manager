<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#project-manager.Subprojects#</property>
<!-- Subproject Portlet Start -->
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-middle">
    <listtemplate name="subproject">
    </listtemplate>
  </td>
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
</tr>
</table>
<!-- Subproject Portlet Ends -->
