<master src="../www/lib/master">
  
  <property name="title">@task_term@ #@task_id@:
    @task_info.task_title;noquote@ @closed_message@</property>
  <property name="context">@context;noquote@</property>
  <property name="project_item_id">@project_item_id@</property>
  
  <if @task_info.live_revision@ ne @task_info.revision_id@>
    <h4>#project-manager.lt_not_current_select_live#</h4>
  </if>

  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    
    <tr>
      <td valign="top">
      
      <if @process_html@ not nil>
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="list">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th>#project-manager.Process_status#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>

          <tr>
            <td class="list-bottom-bg" colspan="3">@process_html;noquote@</td>
          </tr>
        </table>
        <p />
      </if>

  <include
    src="/packages/project-manager/lib/task-info-portlet"
	  &task_info=task_info
	  task_edit_url=@task_edit_url@
	  task_revision_id=@task_revision_id@/>
        
        <P />
        
  <include
    src="/packages/project-manager/lib/categories-portlet"
    item_id="@task_revision_id@" />

        <if 0 eq 1>
          <if @notification_chunk@ not nil>
            @notification_chunk;noquote@
          </if>
        </if>
        
      </td>
      <td>
        &nbsp;
      </td>
      <td valign="top">

      <include src="/packages/project-manager/lib/task-date-portlet"
	  &task_info=task_info
	  />

        <p />

	<include
	  src="/packages/project-manager/lib/task-assignee-portlet"
	  task_id="@task_id@"
	  return_url="@return_url@" />

        <p />

        <include src="/packages/project-manager/lib/task-logger-portlet"
	  project_item_id="@project_item_id@"
	  master="@portlet_master@"
	  logger_project="@logger_project@"
	  logger_days="@logger_days@"
	  return_url="@return_url;noquote@"
	  pm_url="@package_url;noquote@"
	  &task_info=task_info
	  use_days_p="@use_days_p@"
	  pm_task_id="@task_id@" />

        <P />
	    <include src="/packages/project-manager/lib/task-dependency-portlet"

	         task_id="@task_id@"
		 task_term="@task_term@"
		 return_url="@return_url@" 
	         fmt= @fmt@ />
        
      </td>
    </tr>
  </table>
</table>    
  
    

