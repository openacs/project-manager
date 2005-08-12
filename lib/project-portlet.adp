  <master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">
  <if @project.write_p@ eq t>
    <a href="@edit_url@">
      <img border="0" src="/shared/images/Edit16.gif"
	alt="#acs-kernel.common_Edit#" />
    </a>
  </if>
  <if @project.create_p@ eq t>
    <a href="@permissions_url@">
      <img border="0" src="resources/padlock.gif" alt="#project-manager.Set_permissions#" />
    </img>
    </a>
  </if>
  &nbsp;&nbsp;@project_term@ @project.project_name@
  </property>
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
	<if @use_goal_p@ eq 1>
	  <tr>
	    <td class="highlight">#project-manager.Goal_1#</td>
	    <td class="fill-list-bg">@project.goal@</td>
	  </tr>
	</if>
	<tr>
	  <td class="highlight" valign="top">#project-manager.Status#</td>
	  <td class="fill-list-bg">
		<if @project.status_type@ eq "o">
		    <b>#project-manager.Open#</b> / <i><a title="#project-manager.Close_project#" href=@close_url@>#project-manager.Close#</a></i>
		</if>
	        <else>
		    <b>#project-manager.Closed#</b> <small>(<a title="Rate this project#" href=@rate_url@>Rate</a>)</small>
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
	  <th colspan="2" align="center">Dates</th>
	</tr>
	<tr>
	  <td class="highlight">#project-manager.Start#</td>
	  <td class="fill-list-bg">@project.planned_start_date@</td>
	</tr>
	<tr>
	  <td class="highlight">#project-manager.Earliest_finish#</td>
	  <if @project.ongoing_p@ eq f>
	    <td class="fill-list-bg">@project.earliest_finish_date@</td>
	  </if>
	  <else>
	    <td class="fill-list-bg">#project-manager.Ongoing#</td>
	  </else>
	</tr>
	<tr>
	  <td class="highlight">#project-manager.Latest_finish#</td>
	  <if @project.ongoing_p@ eq f>
	    <td class="fill-list-bg">
	      <b>@project.latest_finish_date@</b>
	    </td>
	  </if>
	  <else>
	    <td class="fill-list-bg">#project-manager.Ongoing#</td>
	  </else>
	</tr>
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