<a name=top></a> 
  <a href="#viewoptions" class="button">View options</a>
  <if @display_p@ eq d>
  <a href="?display_p=l&date=@date@#top" class="button">By latest finish</a>
  </if>
  <else>
  <a href="?display_p=d&date=@date@#top" class="button">By deadline</a>
  </else>
   <br>
<br>
  <form method="post" action="@base_url@task-add-edit">
    <input type="submit" value="Edit Tasks" />
    @edit_hidden_vars;noquote@
      
    @calendar;noquote@
    
  </form>

  <a name="viewoptions"><h3>View options</h3></a>

  <a href="@here;noquote@" class="button">@hide_show_closed;noquote@</a>


  <h3>Users to view</h3>

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
    <input type="submit" value="Save" />
  </form>
