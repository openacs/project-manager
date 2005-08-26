  <if @categories:rowcount@ gt 0>
    <master src="@default_layout_url;noquote@" />
    <property name="portlet_title">#project-manager.Categories#</property>
<table width="100%">
    <tr>
      <td colspan="2" class="fill-list-bottom">
	<table border="0" cellpadding="1" cellspacing="1" width="100%">
	  <tr>
	    <td class="fill-list-bg">
	      <ul>
                <multiple name="categories">
                  <li>@categories.tree_name@:
                    <group column="tree_id" delimiter=", ">
                      @categories.category_name@
                    </group>
                  </li>
                </multiple>
	      </ul>
	    </td>
	</table>
      </td>
    </tr>
</table>
  </if>