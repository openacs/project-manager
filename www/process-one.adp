<master />

<link rel="stylesheet" href="/resources/project-manager/style.css" type="text/css" />

<property name="title">#project-manager.One_process#</property>
<property name="context_bar">@context_bar;noquote@</property>

#project-manager.Process_tasks#

<ul>
  <li> #project-manager.lt_Use_all_tasks_in_this#<p />
  <li> 
    <form action="process-task-add-edit" method="post"> 
#project-manager.lt_add_new_tasks#
        <input type="hidden" name="process_id" value="@process_id@">
      <input type="submit" name="submit" value="#project-manager.Go#" />
    </form>
  </li>
</ul>


<listtemplate name="tasks"></listtemplate>


