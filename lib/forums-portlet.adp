<master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">#forums.Forums#</property>
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-middle">
    <include src="/packages/forums/lib/message/threads-chunk" forum_id="@forum_id@" moderate_p="@permissions.moderate_p@" admin_p="@permissions.admin_p@" orderby="last_child_post,desc" base_url="@base_url@">
  </td>
  <td class="fill-list-right2">&nbsp;</td>
</tr>
</table>
  