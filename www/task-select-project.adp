<master>
<property name="context">@context@</property>
<property name="title">@title@</property>

  <table cellpadding="3" cellspacing="3">
    
    <tr>
      
      <td class="list-filter-pane" valign="top" width="200">
        
        <form method=post name=search action=task-select-project>
          #project-manager.Project_Search#<br />
          <input type=text name=searchterm value="@searchterm_copy@" size="15" />
          @hidden_vars;noquote@
        </form>

        <listfilters name="projects"></listfilters>

    </td>

    <td class="list-list-pane" valign="top">

        <listtemplate name="projects"></listtemplate>

    </td>

  </tr>

</table>

