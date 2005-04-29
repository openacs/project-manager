<master src="lib/master">

  <link rel="stylesheet" href="style.css" type="text/css" />
  
  <property name="title">@task_term@s</property>
  <property name="context">@context@</property>
  
  
  <table cellpadding="3" cellspacing="3">
    
    <tr>
      
      <td class="list-filter-pane" valign="top" width="200">
        
        <form method=post name=search action=tasks>
          Search:<br />
          <input type=text name=searchterm value="@searchterm@" size="12" />
          @hidden_vars;noquote@
        </form>

        <listfilters name="tasks"></listfilters>

    </td>

    <td class="list-list-pane" valign="top">

        <listtemplate name="tasks"></listtemplate>

    </td>

  </tr>

</table>



