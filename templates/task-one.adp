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

  <include
    src="/packages/project-manager/lib/task-info-portlet"
	  &task_info=task_info
          process_html=@process_html;noquote@
	  task_edit_url=@task_edit_url@
	  task_revision_id=@task_revision_id@ />
        
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
      <td width="20%" valign="top">
       
      <include src="/packages/project-manager/lib/task-dates-portlet"
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
        
      </td>
    </tr>
  </table>
</table>    
  
    

