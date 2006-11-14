<table border="0" class="list" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <th align="left" valign="top" width="10">
      <img src="/resources/project-manager/tl-e6e6fa" align="top" />
    </th>
    <th>#project-manager.Related_task_terms#</th>
    <th align="right" valign="top" width="10">
      <img src="/resources/project-manager/tr-e6e6fa" align="top" />
    </th>
  </tr>
  <tr>
    <td colspan="2" class="list-bottom-bg">
      <listtemplate name="related_tasks"></listtemplate>
    </td>
    <td class="list-right-bg">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" class="list-bottom-bg">
      <form action="task-link" method="post">
        #project-manager.Link_task# 
        <input type="text" name="to_task" size="7" />
        <input type="hidden" name="from_task" value="@task_id;noquote@" />
        <input type="hidden" name="return_url" value="@return_url@" />
      </form>
    </td>
    <td class="list-right-bg">&nbsp;</td>
  </tr>
</table>
