<master src="@default_layout_url;noquote@" />
<property name="portlet_title">#project-manager.Dates#</property>
<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
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
	<td class="highlight">#project-manager.Task_hours_completed#</td>
	<td class="fill-list-bg">#project-manager.lt_projectactual_hours_c#</td>
      </tr>
    </table>
  </td>
</tr>
</table>
