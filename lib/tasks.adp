<if @display_mode@ eq "list">
  <listtemplate name="tasks">
  </listtemplate>
    <if @more_p@ eq 1>
        <br>
        <if @instance_id@ not nil>
            <center><a class="button" href="project-manager/tasks?instance_id=@instance_id@">#project-manager-portlet.More#</a></center>
        </if>
        <else>
            <center>
                 <a class="button" href="project-manager/tasks?is_observer_p=f">#project-manager-portlet.More#</a>
            </center>
        </else>
       <br>
    </if>
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
  <table cellpadding="3" cellspacing="3" border="0" width="100%">
      <td class="list-filter-pane" valign="top">
	<form method="post" name="search" action="tasks">
	  #project-manager.Search#<br />
	  <input type="text" name="searchterm" value="@searchterm@" size="12" />
	  @hidden_vars;noquote@
	</form>
	<listfilters name="tasks" style="select-menu">
	</listfilters>
      </td>
      </tr><tr>
      <td class="list-list-pane" valign="top">
	<listtemplate name="tasks">
	</listtemplate>
      </td>
    </tr>
  </table>
</if>
<ul>
<li>#project-manager.Estimated_Hours#: @total_estimated_hours@ (@total_estimated_hours_max@)</li></ul>