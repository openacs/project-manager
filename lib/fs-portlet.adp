<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#file-storage.Folder#</property>
<!-- FS Portlet Start -->
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-middle">
<include src="/packages/file-storage/www/folder-chunk" folder_id="@folder_id@" allow_bulk_actions="1" fs_url="@base_url@">
  </td>
</tr>
</table>
 <!-- FS Portlet Stop -->
