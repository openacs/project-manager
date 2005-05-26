<master src="lib/master">
  
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

        <table border="0" cellpadding="0" cellspacing="0" width="100%"
          class="list">
          
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>

            <if @task_info.percent_complete@ ge 100>
              <th class="shaded">
            </if>
            <else>
              <th>
            </else>
            <if @task_info.write_p@ eq t>
              <a href="@task_edit_url;noquote@">
                <img border="0" src="/shared/images/Edit16.gif"
                  alt="Edit">
              </a>
            </if>
              <a href="@print_link@">
                <img border="0" src="resources/print-16.png"
                  alt="Print">
              </a>
            <if @task_info.create_p@ eq t>
              <a href="@permissions_url@">
                <img border="0" src="resources/padlock.gif" alt="Set permissions"></img>
              </a>
            </if>
	    <if @task_info.priority@ ge @urgency_threshold@>
	     <font color=red>
	     </if>
	     <else>
	     <font>  
	     </else>
            @task_term@ #@task_id@: @task_info.task_title@
	    </font>
            </th>

            <th align="left">
              <a href="task-delete?task_item_id=@task_id@">
                <img border="0" src="/shared/images/Delete16.gif">
              </a>
            </th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          
          <tr>
            <td colspan="3">
              
              <table border=0 cellpadding=3 cellspacing=1 width="100%"> 
                
                <tr>
                  <td class="subheader">#project-manager.Description#</td>
                </tr>
                
                <tr>
                  <td class="list-bg">@task_info.description;noquote@</td>
                </tr>

                <tr>
                  <td class="list-bg" align="right">-- @task_info.creation_user@</td>
                </tr>

                <tr>

                <tr>
                  <td class="subheader">#project-manager.Comments#</th>
                </tr>

                <tr>
                  <td class="list-bg">@comments;noquote@
                    <P />
                    @comments_link;noquote@
                  </td>
                </tr>
                
                <tr>
                  <td class="subheader">#project-manager.Actions#</td>
                </tr>
                
                <tr>
                  <td class="list-bottom-bg">
                    <ul> 
                      <li> <a href="task-revisions?task_id=@task_id@">#project-manager.View_task_changes#</a></li>
                    </ul>
                  </td>
                </tr>

              </table>
              <td class="list-right-bg">&nbsp</td>

        </table>
        
        <P />
        
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

        <table border="0" cellpadding="0" cellspacing="0" width="100%"
          class="list">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th>#project-manager.Dates#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <table border="0" class="list" width="100%">
                <tr>
                  <td class="highlight">#project-manager.Earliest_start#</td>
                  <td>@task_info.earliest_start@&nbsp;</td>
                </tr>
                
                <tr>
                  <td class="highlight">#project-manager.Earliest_finish#</td>
                  <td>@task_info.earliest_finish@</td>
                </tr>
                
                <tr>
                  <td class="highlight">#project-manager.Latest_start#</td>
                  <td>@task_info.latest_start@</td>
                </tr>
                
                <tr>
                  <td class="highlight">#project-manager.Latest_finish#</td>
                  <td><b>@task_info.latest_finish@</b></td>
                </tr>

                <if @task_info.latest_finish@ ne @task_info.end_date@>
                  <tr>
                    <td class="highlight">#project-manager.Deadline_1#</td>
                    <td><b>@task_info.end_date@</b></td>
                  </tr>
                </if>

              </table>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
        </table>
        <p />
        
        <table border="0" class="list" width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th>#project-manager.Assignees#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <listtemplate name="people"></listtemplate>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <ul>
                <li>@assignee_add_self_widget;noquote@</li>
                <if @assigned_p@>
                  <li><a href="@assignee_remove_self_url;noquote@">#project-manager.Remove_myself#</a></li>
                </if>
              </ul>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
        </table>
    
        <p />
        
        <table border="0" cellpadding="0" cellspacing="0"
          id="rightcontent" class="list" width="100%">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th colspan="2">#project-manager.Logger#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          
          <tr class="list-filter-header">
            <td class="list-bottom-bg" align="center" colspan="3">
	        #project-manager.lt_Priority_task_infopri#<br />
              <if @use_days_p@ true>
                #project-manager.lt_Days_remaining_task_i#<br />
              </if>
              <else>
                #project-manager.lt_Hours_remaining_task_#<br />
              </else>
              <if @task_info.slack_time@ nil>
                #project-manager.Slack_na#
              </if>
              <elseif @task_info.slack_time@ lt 1>
                #project-manager.Slack# <font color="red">@task_info.slack_time@</font><br />
              </elseif>
              <else>
                #project-manager.lt_Slack_task_infoslack_#<br />
              </else>

              #project-manager.lt_Complete_task_infoper#
            </td>
            <td class="list-right-bg">&nbsp;</td>

          </tr>
          
          <tr class="list-bottom-bg">

            <td valign="top" colspan="3" class="list-bottom-bg">
              <form action="task-one" method="post">
                @variable_widget;noquote@
                @variable_exports;noquote@
                @day_widget;noquote@
                <input type="submit" name="submit" value="View" />
              </form>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
          
          <tr>
            <td colspan="3" class="list-bottom-bg">
              <include src="/packages/logger/lib/entries"
                project_id="@logger_project@"
                variable_id="@logger_variable_id@"
                filters_p="f"
                pm_project_id="@project_item_id@" 
                pm_task_id="@task_id@" 
                start_date="@then_ansi@"
                end_date="@nextyear_ansi@" 
                url="@logger_url;noquote@" 
                add_link="@log_url;noquote@" 
                show_orderby_p="f"
                project_manager_url="@package_url;noquote@" 
                return_url="@return_url;noquote@" />
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
        </table>

        <P />
        
        <table border="0 class="list" width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th>#project-manager.lt_task_terms_this_depen#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <listtemplate name="dependency"></listtemplate>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
        </table>
        
        <P />
        
        <table border="0" class="list" width="100%" cellspacing="0" cellpadding="0">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th>#project-manager.lt_task_terms_depending_#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          <tr>
            <td colspan="2">
              <listtemplate name="dependency2"></listtemplate>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
        </table>
        
        <p />
        
        <table border="0" class="list" width="100%" cellspacing="0" cellpadding="0">
          <tr>
            <th align="left" valign="top" width="10">
              <img src="resources/tl-e6e6fa" align="top" />
            </th>
            <th>#project-manager.Related_task_terms#</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <listtemplate name="xrefs"></listtemplate>
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <form action="task-link" method="post">
                #project-manager.Link_task# 
                <input type="text" name="to_task" size="7" />
                <input type="hidden" name="from_task" value="@task_id;noquote@" />
                <input type="hidden" name="return_url" value="@return_url@" />
            </td>
            <td class="list-right-bg">&nbsp;</td>
          </tr>
        </table>
        
      </td>
    </tr>
  </table>
</table>    
  
    

