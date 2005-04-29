<master />

<link rel="stylesheet" href="style.css" type="text/css" />

<property name="title">One process</property>
<property name="context_bar">@context_bar;noquote@</property>

Process tasks:

<ul>
  <li> Use all tasks in this process: @use_link;noquote@<p />
  <li> 
    <form action="process-task-add-edit" method="post"> 
      Add 
      <input type="hidden" name="process_id" value="@process_id@">
      <input type="text"   name="number" size="3" value="1" />
      new task(s) to this process
      <input type="submit" name="submit" value="Go" />
    </form>
  </li>
</ul>


<listtemplate name="tasks"></listtemplate>

