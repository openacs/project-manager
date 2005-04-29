<master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>
  
  <if @confirmed_p@ eq y>

    Done.

  </if>
  <else>
    
    Are you ready to sync with these URLs?
    <ul>
      <list name="logger_URLs">
        <li> @logger_URLs:item@ </li>
      </list>
    </ul>

    <p />
    <a href="@confirm_link@">Begin synchronization<a> (be patient,
    this takes a long time, you can read the log files to see what's
    happening if you like.)

  </else>
