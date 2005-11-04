<HTML>
<HEAD>
<TITLE>@task_term@ #@task_id@: @task_info.task_title@</TITLE>
</HEAD>

<BODY>

<TABLE border="0">
<TR>
<TD valign="top">

<table border="1" cellpadding="0" cellspacing="0" width="100%">

  <tr>
    <th bgcolor="lavender" colspan="3">
	@project_title@ <br>
	@task_term@ #@task_id@: @task_info.task_title@
    </th>

<tr>
<td colspan="3">

<table border=0 cellpadding=3 cellspacing=1 width="100%">

<tr>
<th colspan="2">#project-manager.Description#</th>
<tr>
<td colspan="2">@task_info.description;noquote@
</tr>

<tr>
<td colspan="2">
    <if @show_comment_p@ eq t>
      <p /><h3>#project-manager.Comments#</h3>@comments;noquote@
    </if>
    <else>
      <font size="-2"><p />@show_comment_link;noquote@</font>
    </else>
</td>
</tr>

</table>
</table>

</TD>
<TD valign="top">

<table border="0">
<tr>
<th bgcolor="lavender">#project-manager.Assignees#</th>
</tr>

<tr>
<td><listtemplate name="people"></listtemplate></td>
</tr>

<tr>
<th bgcolor="lavender">#project-manager.Work#</th>
</tr>

<tr>
<td>#project-manager.lt_task_infopercent_comp#</td>
</tr>

<tr>
<td>#project-manager.lt_task_infoestimated_ho#</td>
</tr>

<tr>
<td>#project-manager.lt_Slack_time_task_infos#</td>
</tr>

<tr>
<th bgcolor="lavender">#project-manager.Dates#</th>

<tr><td>

<table border="0" cellpadding="0" cellspacing="0">
<tr>
<td>#project-manager.Now#</th>
<td>@task_info.current_time@</td>
</tr>

<tr>
<td>#project-manager.Earliest_start#</th>
<td>@task_info.earliest_start@</td>
</tr>

<tr>
<td>#project-manager.Earliest_finish#</th>
<td>@task_info.earliest_finish@</td>
</tr>

<tr>
<td>#project-manager.Latest_start#</th>
<td>@task_info.latest_start@</td>
</tr>

<tr>
<td>#project-manager.Latest_finish#</th>
<td>@task_info.latest_start@</td>
</tr>
</table>

<tr>
<th bgcolor="lavender">#project-manager.lt_task_terms_this_depen_1#</th>
</tr>

<tr>
<td><listtemplate name="dependency"></listtemplate>
</td>
</tr>

<tr>
<th bgcolor="lavender">#project-manager.lt_task_terms_depending__1#</th>
</tr>

<tr>
<td>
<listtemplate name="dependency2"></listtemplate>
</td>
</tr>

</table>

</TD>
</TR>
</TABLE>


</BODY>
</HTML>

