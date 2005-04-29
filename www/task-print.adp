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
    <th bgcolor="lavender" colspan="3">@task_term@ #@task_id@: @task_info.task_title@</th>

<tr>
<td colspan="3">

<table border=0 cellpadding=3 cellspacing=1 width="100%">

<tr>
<th colspan="2">Description</th>
<tr>
<td colspan="2">@task_info.description;noquote@
</tr>

<tr>
<td colspan="2">
    <if @show_comment_p@ eq t>
      <p /><h3>Comments</h3>@comments;noquote@
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
<th bgcolor="lavender">Assignees</th>
</tr>

<tr>
<td><listtemplate name="people"></listtemplate></td>
</tr>

<tr>
<th bgcolor="lavender">Work</th>
</tr>

<tr>
<td>@task_info.percent_complete@% complete</td>
</tr>

<tr>
<td>@task_info.estimated_hours_work_min@ - @task_info.estimated_hours_work_max@ hrs estimated</td>
</tr>

<tr>
<td>Slack time: @task_info.slack_time@</td>
</tr>

<tr>
<th bgcolor="lavender">Dates</th>

<tr><td>

<table border="0" cellpadding="0" cellspacing="0">
<tr>
<td>Now</th>
<td>@task_info.current_time@</td>
</tr>

<tr>
<td>Earliest start</th>
<td>@task_info.earliest_start@</td>
</tr>

<tr>
<td>Earliest finish</th>
<td>@task_info.earliest_finish@</td>
</tr>

<tr>
<td>Latest start</th>
<td>@task_info.latest_start@</td>
</tr>

<tr>
<td>Latest finish</th>
<td>@task_info.latest_start@</td>
</tr>
</table>

<tr>
<th bgcolor="lavender">@task_term@(s) this depends on.</th>
</tr>

<tr>
<td><listtemplate name="dependency"></listtemplate>
</td>
</tr>

<tr>
<th bgcolor="lavender">@task_term@(s) depending on this @task_term@</th>
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
