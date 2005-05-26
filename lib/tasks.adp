<if @display_mode@ eq "list">
  <listtemplate name="tasks">
  </listtemplate>
</if>
<if @display_mode@ eq "filter">
  <form method="post" name="search" action="tasks">
    #project-manager.Search#<br />
    <input type="text" name="searchterm" value="@searchterm@" size="12" />
    @hidden_vars;noquote@
  </form>
  <listfilters name="tasks">
  </listfilters>
</if>
<if @display_mode@ eq "all">
  <table cellpadding="3" cellspacing="3">
    <tr>
      <td class="list-filter-pane" valign="top" width="200">
	<form method="post" name="search" action="tasks">
	  #project-manager.Search#<br />
	  <input type="text" name="searchterm" value="@searchterm@" size="12" />
	  @hidden_vars;noquote@
	</form>
	<listfilters name="tasks">
	</listfilters>
      </td>
      <td class="list-list-pane" valign="top">
	<listtemplate name="tasks">
	</listtemplate>
      </td>
    </tr>
  </table>
</if>
