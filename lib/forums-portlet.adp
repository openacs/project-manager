<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#forums.Forums#</property>
<!-- Forums Portlet Start -->
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-middle">
   <if @forum_id@ ne "">
    <include src="/packages/forums/lib/message/threads-chunk"
    forum_id="@forum_id@" moderate_p="@permissions.moderate_p@"
    admin_p="@permissions.admin_p@" orderby="last_child_post,desc"
    base_url="@base_url@" &="permissions" page_size="@page_size@">
   </if>
   <else>Create new forum</else>
  </td>
</tr>
</table>
  <!-- Forums Portlet Stop -->
