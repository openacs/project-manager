<master src="lib/master">

  <link rel="stylesheet" href="style.css" type="text/css" />
    
  <property name="title">@project_term@s</property>
  <property name="context">@context;noquote@</property>
  
  <table cellpadding="3" cellspacing="3">
    
    <tr>
      
      <td class="project-filter-pane" valign="top">
        
        <form method=post name=search action=index>
          Search:<br />
          <input type=text name=searchterm value="@searchterm@" size="15" />
          @hidden_vars;noquote@
          <input type="submit" value="Go" />
        </form>
        
        @category_select;noquote@
        
        <listfilters name="projects"></listfilters>
        
      </td>
      
      <td class="list-list-pane" valign="top">
        
        <listtemplate name="projects"></listtemplate>
        
      </td>
      
    </tr>
    
  </table>



