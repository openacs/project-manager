<master src="@default_layout_url;noquote@" />
<property name="portlet_title">Mails</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
	<td>
	    <include src="/packages/mail-tracking/lib/messages" 
		object_id=@project_item_id@
		page_size=100
		page=@page@
		show_filter_p="f"
	    >
	</td>
      </tr>
    </table>
  </td>
</tr>
</table>