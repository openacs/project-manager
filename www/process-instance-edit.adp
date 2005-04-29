<master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>
  

  <form action="process-instance-edit-2">
    <input type="text"   name="my_name" size="50" value="@name@" />
    <input type="hidden" name="instance_id" value="@instance_id@" />
    <input type="hidden" name="process_id" value="@process_id@" />
    <input type="submit" value="Save" />
  </form>
