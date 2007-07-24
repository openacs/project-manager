<master>
  <property name="context">@context;noquote@</property>

<table>
  <tr>
    <td valign="top">
      <div class="portlet">
        <h2>Calendar</h2>
        <div class="portlet-body">
          <include src="/packages/project-manager/lib/task-calendar" format="print" date="@date@" julian_date="@julian_date@" hide_closed_p="@hide_closed_p@" display_p="d" hide_observer_p=t view="@view@" package_id="@package_id@">
        </div>
      </div>
      <div class="portlet">
        <h2>#project-manager.Tasks#</h2>
        <div class="portlet-body">
          <include src="/packages/project-manager/lib/tasks" display_mode=list page=@page@ page_size=30 status_id=1 orderby_p=1 tasks_orderby=@tasks_orderby@ elements=@elements@ is_observer_filter=f filter_party_id="@user_id@" instance_id="@package_id@">
        </div>
      </div>
    </td>
    <td valign="top">
      <div class="portlet">
        <h2>Projects</h2>
        <div class="portlet-body">
          <include src="/packages/project-manager/lib/projects" package_id="@package_id@" assignee_id=@user_id@ filter_p=0 page=@page@ page_size=30 status_id=1 orderby_p=1 projects_orderby=@projects_orderby@ elements=@pm_elements@ current_package_f="@package_id@" actions_p=1>
        </div>
      </div>
      <div class="portlet">
        <h2>Logger</h2>
        <div class="portlet-body">
          <include 
	    src="/packages/logger/lib/entries" 
	    filters_p="f"
      	    show_tasks_p="1"
	    start_date="@then_ansi;noquote@"
	    &="project_ids"
	    user_id="@user_id@"
            end_date="@today_ansi;noquote@"
	    variable_id="@variable_id@"/>
        </div>
      </div>
    </td>
  </tr>

</table>
  

