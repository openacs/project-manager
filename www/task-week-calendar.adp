<master src=lib/master>
<property name=title>Title</property>
<property name=header_stuff><link href="/resources/calendar/calendar.css" rel="stylesheet" type="text/css"></property>

<a name=top></a> 
  <if @display_p@ eq d>
  <a href="?date=@date@&display_p=l#top" class="button">By latest finish</a>
  </if>
  <else>
  <a href="?date=@date@&display_p=d#top" class="button">By deadline</a>
  </else>
   <br>
<br>
 <table class="cal-table-display" cellpadding="0" cellspacing="0" border="0" width="99%">
  <tr>
    <td class="cal-month-title-text">
      <a href="@previous_week_url@"><img border=0 src="<%=[dt_left_arrow]%>" alt="back one week"></a>
      @dates@
      <a href="@next_week_url@"><img border=0 src="<%=[dt_right_arrow]%>" alt="forward one week"></a>
    </td>
  </tr>
  <tr>
  <td>
  
    <table cellpadding="0" cellspacing="0" border="0">
    <multiple name="items">
      <tr>
      <td valign=top class="cal-week">
      @items.start_date_weekday@:
      </td>

      <td width="95%" class="cal-week">
      <a href="@items.add_url@">
         <img border="0" align="right" height="7" width="7"
           src="/resources/acs-subsite/add.gif" alt="#calendar.Add_Item#">
      </a>
      <a href="@items.day_url@">@items.start_date@</a>
      </td>
      </tr>
    
      <tr>
        <td class="cal-week-event" colspan=3>
        <if @items.event_name@ true>
        <table class="cal-week-events" cellpadding="0" cellspacing="0">
        <tbody>
        <group column="day_of_week">
          <if @items.event_name@ true>
            <tr>
            <td>
            <if @items.no_time_p@ true>
            <span class="cal-week-event-notime">
            </if>
            <if @items.no_time_p@ false>
            @items.end_time@
            </if>
            <a href="@items.event_url@">@items.event_name@</a>
	    @items.users_list;noquote@
            <if @items.no_time_p@ true>
            </span>
            </if>
            </td>
            </tr>
           </if>
        </group>
        </tbody>
        </table>
        </if>
        </td>
       </tr>
      </td>
      </tr>
    </multiple>
    </table>
    
  </td>
  </tr>
</table>
<br>
<br>
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
