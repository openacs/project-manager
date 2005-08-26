<master src="@default_layout_url;noquote@" />
<property name="portlet_title">
  @write_html;noquote@&nbsp;&nbsp;@project_term@ @project.project_name@
  </property>
<!-- Project Portlet Start -->
<table width="100%">
  <tr>
    <td bgcolor="#eeeeee" colspan="2" class="fill-list-bottom">
      <table border="0" width="100%" bgcolor="#ffffff" cellspacing="0">
	<tr>
	  <td class="highlight" valign="top">#project-manager.Name_1#</td>
	  <td class="fill-list-bg">@project.project_name@</td>
	</tr>
	<if @use_project_code_p@ eq 1>
	  <tr>
	    <td class="highlight">#project-manager.Code_1#</td>
	    <td class="fill-list-bg">@project.project_code@</td>
	  </tr>
	</if>
	  <tr>
	    <td class="highlight">#project-manager.Customer#</td>
            <if @project.customer_name@ ne "">
              <td class="fill-list-bg"><a href="@contacts_url@@project.customer_id@">@project.customer_name@</td>
            </if> 
            <else>
	      <td class="fill-list-bg">@project.customer_id@</td>
            </else>
	  </tr>
	<tr>
	  <td class="highlight" valign="top">#project-manager.Status#</td>
	  <td class="fill-list-bg">
		<if @project.status_type@ eq "o">
		    <b>#project-manager.Open#</b> / <i><a title="#project-manager.Close_project#" href=@close_url@>#project-manager.Close#</a></i>
		</if>
	        <else>
		    <b>#project-manager.Closed#</b> <small>(<a title="#project-manager.Rate_this_project#" href=@rate_url@>#project-manager.Rate#</a>)</small>
		</else>
	  </td>
	</tr>
	<tr>
	  <td class="highlight" valign="top">#project-manager.Description_1#</td>
	  <td class="fill-list-bg">@project.description;noquote@</td>
	</tr>
	<multiple name="dynamic_attributes">
	  <tr>
	    <td class="highlight">@dynamic_attributes.name@:</td>
	    <td class="fill-list-bg">@dynamic_attributes.value@</td>
	  </tr>
	</multiple>
	<tr>
	  <td class="highlight">#project-manager.Deadline#</td>
	  <if @project.ongoing_p@ eq f>
	    <td class="fill-list-bg">
	      <b>@project.planned_end_date@</b>
	    </td>
	  </if>
	  <else>
	    <td class="fill-list-bg">#project-manager.Ongoing#</td>
	  </else>
	</tr>
	<tr>
	  <td class="highlight">#categories.Categories#</td>
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
	</tr>
      </table>
    </td>
  </tr>
  <tr>
    <td colspan="2" class="fill-list-bottom">
      <ul>
	@project_links;noquote@
	<li>
	  <a href="project-revisions?project_item_id=@project_item_id@">#project-manager.View_project_changes#</a>
	</li>
      </ul>
    </td>
  </tr>
</table>
<!-- Project Portlet Ends -->