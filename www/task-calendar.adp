<master src="lib/master">

  <property name="title">@title@</property>
  <property name="context">@context@</property>
  <property name="header_stuff">@header_stuff;noquote@</property>

  <a href="#viewoptions" class="button">View options</a>
  <a href="#key" class="button">Key</a>

  <form method="post" action="task-add-edit">
    <input type="submit" value="Edit Tasks" />
    @edit_hidden_vars;noquote@
      
    @calendar;noquote@
    
  </form>

  <a name="viewoptions"><h3>View options</h3></a>

  <a href="@here;noquote@" class="button">@hide_show_closed;noquote@</a>

  <a name="key"><h3>Key</h3></a>

  <dl>
    <multiple name="roles">
      <dt>@roles.abbreviation;noquote@</dt>
      <dd>@roles.role;noquote@</dd>
    </multiple>
  </dl>

  <h3>Users to view</h3>

  <form method="post" name="users_to_view" action="calendar-users-update">
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
