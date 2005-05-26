<master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>
  
  <if @confirmed_p@ eq y>

    #project-manager.Done#

  </if>
  <else>
    
    #project-manager.lt_Are_you_ready_to_sync#
    <ul>
      <list name="logger_URLs">
        <li> @logger_URLs:item@ </li>
      </list>
    </ul>

    <p />
    <a href="@confirm_link@">#project-manager.lt_Begin_synchronization#<a> #project-manager.lt_be_patient____this_ta#

  </else>

