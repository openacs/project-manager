<master>
<property name="context_bar">@context_bar;noquote@</property>
<property name="title">@title@</property>


<center>

<form action="process-task-delete-2" method="post">

Are you sure you'd like to delete these @task_term_lower@s?

<input type="submit" name="submit" value="Yes" />
@hidden_vars;noquote@

</form>

</center>
