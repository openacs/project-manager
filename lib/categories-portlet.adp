  <if @cat_length@ gt 0>
    <master src="/packages/project-manager/lib/portlet" />
    <property name="portlet_title">#project-manager.Categories#</property>
    <tr>
      <td colspan="2" class="fill-list-bottom">
	<table border="0" cellpadding="1" cellspacing="1" width="100%">
	  <tr>
	    <td class="fill-list-bg">
	      <ul>
		<list name="categories">
		  <li> @categories:item@
		</list>
	      </ul>
	    </td>
	</table>
      </td>
      <td class="fill-list-right">&nbsp;</td>
    </tr>
  </if>