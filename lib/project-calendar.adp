<a name=top></a> 
  <a href="#pviewoptions" class="button">View options</a>
  <a href="#pkey" class="button">Key</a>
<br>
<br>
  <form method="post" action="@base_url@task-add-edit">
<!--    <input type="submit" value="Edit Tasks" />-->
    @edit_hidden_vars;noquote@
      
    @calendar;noquote@
    
  </form>

  <a name="pviewoptions"><h3>View options</h3></a>

<!--  <a href="@here;noquote@" class="button">@hide_show_closed;noquote@</a>-->

  <a name="pkey"><h3>Key</h3></a>

  <dl>
    <multiple name="roles">
      <dt>@roles.abbreviation;noquote@</dt>
      <dd>@roles.role;noquote@</dd>
    </multiple>
  </dl>

  <h3>Users to view</h3>

  <form method="post" name="users_to_view" action="@base_url@calendar-users-update">
    @edit_hidden_vars;noquote@
    <multiple name="users">

      <if @users.checked_p@ true>
        <input type="checkbox" checked="checked" name="party_id" value="@users.party_id@" />
        @users.name@ <br />
      </if>
      <else>
        <input type="checkbox" name="party_id" value="@users.party_id;noquote@" />
        @users.name@ <br />
      </else>

    </multiple>

    <input type="submit" value="Save" />
  </form>