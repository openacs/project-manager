<master src="lib/master" />

  <if @project.status_type@ eq c>
    <property name="title">@my_title;noquote@ -- Closed</property>
  </if>
  <else>
    <property name="title">@my_title;noquote@</property>
  </else>
  <property name="context">@context;noquote@</property>
  <property name="project_item_id">@project_item_id@</property>
  
  <if @project.live_revision@ ne @project.project_id@>
  <h4>(not current, select live version from the <a href="project-revisions?project_item_id=@project_item_id@">task change</a> page)</h4>
  </if>
  
  <table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr>
    <td valign="top">
      
      <table border="0" cellpadding="0" cellspacing="0" width="100%" class="list">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <if @project.status_type@ eq c>
            <th class="shaded">
          </if>
          <else>
            <th class="project">
          </else>
            <a href="@edit_url@">
              <img border="0" src="/shared/images/Edit16.gif"
                alt="Edit" />
            </a>
            
            &nbsp;&nbsp;@project_term@
            
          </th>
        <th align="right" valign="top" width="10" class="project">
          <img src="resources/tr-9999cc" align="top" />
        </th>
          
        </tr>
        
        <tr>
          <td bgcolor="#eeeeee" colspan="2" class="fill-list-bottom">
            
            <table border="0" width="100%" bgcolor="#ffffff" cellspacing="0">
              
              <tr>
                <td class="highlight" valign="top">Name:</td>
                <td class="fill-list-bg">@project.project_name@</td>
              </tr>
              
              <if @use_project_code_p@ eq 1>
                <tr>
                  <td class="highlight">Code:</td>
                  <td class="fill-list-bg">@project.project_code@</td>
                </tr>
              </if>
              
              <if @use_goal_p@ eq 1>
                <tr>
                  <td class="highlight">Goal:</td>
                  <td class="fill-list-bg">@project.goal@</td>
                </tr>   
              </if>
              
              <tr>
                <td class="highlight" valign="top">Description:</td>
                <td class="fill-list-bg">@project.description;noquote@</td>
              </tr>
              
            </table>
            </td>
            <td class="fill-list-right">&nbsp;</td>
        </tr>
      </table>
      
      <p />
      
      <table border="0" cellpadding="0" cellspacing="0" width="100%" class="list">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project">Dates</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>
        
        <tr>
          <td colspan="2" class="fill-list-bottom">
            <table border="0" cellpadding="1" cellspacing="1" width="100%">
              <tr>
                <td class="highlight">Start</td>
                <td class="fill-list-bg">@project.planned_start_date@</td>
              </tr>
              
              <tr>
                <td class="highlight">Earliest finish</td>
                <if @project.ongoing_p@ eq f>
                  <td class="fill-list-bg">@project.earliest_finish_date@</td>
                </if>
                <else>
                  <td class="fill-list-bg">Ongoing</td>
                </else>
              </tr>
              
              <tr>
                <td class="highlight">Latest finish</td>
                <if @project.ongoing_p@ eq f>
                  <td class="fill-list-bg"><b>@project.latest_finish_date@</b></td>
                </if>
                <else>
                  <td class="fill-list-bg">Ongoing</td>
                </else>
              </tr>
              
              <tr>
                <td class="highlight">Task hours completed</td>
                <td class="fill-list-bg">@project.actual_hours_completed@ of @project.estimated_hours_total@</td>
              </tr>
              
            </table>
          </td>
          <td class="fill-list-right">
        </tr>
      </table>
      
      <p />
      
      <table border="0" class="list" width="100%" cellpadding="0">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project">Assignees</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>
        <tr>
          <td colspan="2" class="fill-list-middle">
            <listtemplate name="people"></listtemplate>
          </td>
          <td class="fill-list-right">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="2" class="fill-list-bottom">
            <ul>
              <if @roles_listbox_p@>
                <li>@assignee_add_self_widget;noquote@</li>
              </if>
              <if @assigned_p@>
                <li><a href="@assignee_remove_self_url;noquote@">Remove myself</a></li>
              </if>
              <li><a href="@assignee_edit_url;noquote@">Edit assignees</a></li>
            </ul>
          </td>
          <td class="fill-list-right">&nbsp</td>
        </tr>
      </table>

      <p />

      <if @use_project_customizations_p@>
        <p />
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="list">
          <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project">Project information</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
          </tr>
          
          <tr>
            <td colspan="2" class="fill-list-bottom">
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td class="highlight">Customer</td>
                  <td class="fill-list-bg"><a href="@customer_link@">@custom.customer_name@</a></td>
                </tr>
              </table>
            </td>
            <td class="fill-list-right">&nbsp</td> 
          </tr>
        </table>
      </if>
      
      <p />
      
      <table border="0" cellpadding="0" cellspacing="0" width="100%" class="list">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project">Categories</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>
        
        <tr>
          <td colspan="2" class="fill-list-bottom">
            <table border="0" cellpadding="1" cellspacing="1" width="100%">
              <tr>
                <td class="fill-list-bg">
                  
                  <ul>
                    <list name="categories">
                      <if @categories:rowcount@ gt 0>
                        <li> @categories:item@
                      </if>
                    </list>
                  </ul>
                  
                </td>
            </table>
          </td>
          <td class="fill-list-right">&nbsp;</td> 
        </tr>
      </table>
      
      <p />

      <if @use_subprojects_p@>
        <table class="list" cellpadding="3" cellspacing="1" width="100%" border="0">
          <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
            <th colspan="2">Subprojects</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
          </tr>
          
          <tr class="list-button-bar">
            <td><span class="list-button-header" colspan="3"><a
                  href="add-edit?parent_id=@project_item_id@" class="list-button"
                  title="Add a subproject to this project">Add subproject</a></span>
              
              <listtemplate name="subproject"></listtemplate>
              
            </td>
          </tr>
        </table>

        <p />
      </if>

      <table class="list" cellpadding="0" cellspacing="0" width="100%" border="0">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project" colspan="2">Comments</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>
        
        <tr class="list-button-bar">
          <td colspan="3" class="fill-list-bottom">
            @comments;noquote@
            <ul>
              <li> @comments_link;noquote@
            </ul>
          </td>
          <td class="fill-list-right">&nbsp;</td>
          </tr>
      </table>

      <p />
      <table class="list" cellpadding="0" cellspacing="0" width="100%" border="0">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project" colspan="2">Actions</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>
        
        <tr>
          <td colspan="3" class="fill-list-bottom">
            <ul> 
              <li> <a href="project-revisions?project_item_id=@project_item_id@">View project changes</a></li>
            </ul>
          </td>
          <td class="fill-list-right">&nbsp;</td>
        </tr>
        
      </table>

    </td>
    <td valign="top">
      
      <if 0 eq 1>
        TASKS
      </if>

      <table border="0" cellpadding="0" cellspacing="1" width="100%"
        id="rightcontent" class="list">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project">@task_term@</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>

        <if @instance_html@ not nil>
          <tr>
            <td colspan="2" class="fill-list-middle">@instance_html;noquote@</td>
            <td class="fill-list-right2">&nbsp;</td>
          </tr>
        </if>

        <tr>
          <td colspan="2" class="fill-list-middle">
            <listtemplate name="tasks"></listtemplate>
          </td>
          <td class="fill-list-right2">&nbsp;</td>
        </tr>
        <tr class="list-button-bar">
          <td class="fill-list-bottom" colspan="2">  
            <ul>
              <li> 
                <form action="task-add-edit" method="post"> 
                  Add 
                  <input type="hidden" name="project_item_id" value="@project_item_id@" />
                  <input type="hidden" name="return_url"
                value="@return_url@" />
                  <input type="text"   name="new_tasks" size="3" value="1" />
                  Tasks
                  <input type="submit" name="submit" value="Go" />
                </form>
              </li>

              <li>
                <form action="process-one" method="post"> 
                  <input type="hidden" name="project_item_id" value="@project_item_id@" />
                  <input type="hidden" name="return_url" value="@return_url@" />
                  <select name="process_id">
                    @processes_html;noquote@
                  </select>
                  <input type="submit" name="submit" value="Use" />
                </form>

                <if @instance_id@ not nil>
                  <li> <a href="@process_reminder_url@">Send a process reminder</a></li>
                </if>

            </ul>
            
          </td>
          <td class="fill-list-right">&nbsp;</td>
        </tr>
        
      </table>
      
      <p />
      
      <table border="0" cellpadding="0" cellspacing="0"
        id="rightcontent" class="list" width="100%">
        <tr>
          <th align="left" valign="top" width="10" class="project">
            <img src="resources/tl-9999cc" align="top" />
          </th>
          <th class="project">Logger</th>
          <th align="right" valign="top" width="10" class="project">
            <img src="resources/tr-9999cc" align="top" />
          </th>
        </tr>
        
        <tr class="list-button-bar">
          <td class="fill-list-middle" valign="top" colspan="2">
            <form action="one" method="post">
              @variable_widget;noquote@
              @variable_exports;noquote@
              @day_widget;noquote@
              <input type="submit" name="submit" value="View" />
            </form>
          </td>
          <td class="fill-list-right2">&nbsp;</td>
        </tr>
        
        <tr>
          <td colspan="2" class="fill-list-bottom">
            <include src="/packages/logger/lib/entries"
              project_id="@project.logger_project;noquote@"
              variable_id="@logger_variable_id;noquote@"
              filters_p="f"
              show_tasks_p="1"
              pm_project_id="@project_item_id;noquote@" 
              start_date="@then_ansi;noquote@" 
              end_date="@today_ansi;noquote@" 
              url="@logger_url;noquote@" 
              add_link="@log_url;noquote@"
              project_manager_url="@package_url;noquote@" 
              return_url="@return_url;noquote@" /> 
          </td>
          <td class="fill-list-right">&nbsp;</td>
        </tr>
      </table>
    </td>
  </tr>
</table>
