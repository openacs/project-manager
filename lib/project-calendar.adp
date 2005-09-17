<a name=top_p></a> 
 <!-- <a href="#pviewoptions" class="button">#project-manager.View_options#</a>-->
<br>
<br>
  <form method="post" action="@base_url@task-add-edit">
<!--    <input type="submit" value="Edit Tasks" />-->
    @edit_hidden_vars;noquote@
      
    @calendar;noquote@
    
  </form>

<!--  <a name="pviewoptions"><h3>#project-manager.View_options#</h3></a>

  <a href="@here;noquote@" class="button">@hide_show_closed;noquote@</a>-->

  <h3>#project-manager.Users_to_view#</h3>

  <form method="post" name="users_to_view" action="@base_url@calendar-users-update">
    @edit_hidden_vars;noquote@
    <select name="party_id" multiple>
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

