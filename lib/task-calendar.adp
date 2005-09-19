<if @format@ ne print>
<a name=top></a> 
  <a href="#viewoptions" class="button">#project-manager.View_options#</a>
  <if @display_p@ eq d>
  <a href="?display_p=l&date=@date@#top" class="button">#project-manager.By_latest_finish#</a>
  </if>
  <else>
  <a href="?display_p=d&date=@date@#top" class="button">#project-manager.By_deadline#</a>
  </else>
  <a target="format_print" href="?format=print" class="button">#project-manager.Format_print#</a>
   <br>
<br>
  <form method="post" action="@base_url@task-add-edit">
    <input type="submit" value="#project-manager.Edit_Tasks#" />
    @edit_hidden_vars;noquote@
</if>      
    @calendar;noquote@

<if @format@ ne print>
  </form>

  <a name="viewoptions"><h3>#project-manager.View_options#</h3></a>

  <a href="@here;noquote@" class="button">@hide_show_closed;noquote@</a>


  <h3>#project-manager.Users_to_view#</h3>

  <form method="post" name="users_to_view" action="@base_url@calendar-users-update">
    @edit_hidden_vars;noquote@
    <select name= "party_id" multiple>	
    <multiple name="users">
      <if @users.checked_p@ true>
        <option selected value="@users.party_id@" />
        @users.name@ <br />
      </if>
      <else>
	<option value="@users.party_id@" />
        @users.name@ <br />
      </else>
    </multiple>
</select>
    <input type="submit" value="#acs-kernel.common_Save#" />
  </form>
</if>
