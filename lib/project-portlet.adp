  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr>
      <td valign="top">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="list">
	  <tr>
	    <th align="left" valign="top" width="10" class="project">
	      <img src="resources/tl-9999cc" align="top" />
	    </th>
	    <if @project.status_type@ eq c>
	      <th class="shaded">
	    </if>
	    <else>
	      <th class="project">
	    </else>
          <if @project.write_p@ eq t>
            <a href="@edit_url@">
              <img border="0" src="/shared/images/Edit16.gif"
                alt="Edit" />
            </a>
          </if>
          <if @project.create_p@ eq t>
            <a href="@permissions_url@">
              <img border="0" src="resources/padlock.gif" alt="Set permissions"></img>
            </a>
          </if>
	    &nbsp;&nbsp;@project_term@
	  </th>
	    <th align="right" valign="top" width="10" class="project">
	      <img src="resources/tr-9999cc" align="top" />
	    </th>
	  </tr>
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
		  <td class="highlight" valign="top">#project-manager.Description_1#</td>
		  <td class="fill-list-bg">@project.description;noquote@</td>
		</tr>
	      </table>
	    </td>
	    <td class="fill-list-right">&nbsp;</td>
	  </tr>
        <tr>
          <td colspan="2" class="fill-list-bottom">
            <ul> 
              <li> <a href="project-revisions?project_item_id=@project_item_id@">#project-manager.View_project_changes#</a></li>
            </ul>
          </td>
          <td class="fill-list-right">&nbsp;</td>
        </tr>

	</table>

