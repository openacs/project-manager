<master src="lib/master">
  
  <property name="title">@task_term@ #@task_id@:
    @task_info.task_title;noquote@ @closed_message@</property>
  <property name="context">@context;noquote@</property>
  
  <if @task_info.live_revision@ ne @task_info.revision_id@>
    <h4>(not current, select live version from the <a href="task-revisions?task_id=@task_info.item_id@">task change</a> page)</h4>
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
            <th>Process status</th>
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

              <a href="@task_edit_url;noquote@">
                <img border="0" src="/shared/images/Edit16.gif"
                  alt="Edit">
              </a>
              <a href="@print_link@">
                <img border="0" src="resources/print-16.png"
                  alt="Print">
              </a>
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
                  <td class="subheader">Description</td>
                </tr>
                
                <tr>
                  <td class="list-bg">@task_info.description;noquote@</td>
                </tr>

                <tr>
                  <td class="list-bg" align="right">-- @task_info.creation_user@</td>
                </tr>

                <tr>

                <tr>
                  <td class="subheader">Comments</th>
                </tr>

                <tr>
                  <td class="list-bg">@comments;noquote@
                    <P />
                    @comments_link;noquote@
                  </td>
                </tr>
                
                <tr>
                  <td class="subheader">Actions</td>
                </tr>
                
                <tr>
                  <td class="list-bottom-bg">
                    <ul> 
                      <li> <a href="task-revisions?task_id=@task_id@">View task changes</a></li>
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
            <th>Dates</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          <tr>
            <td colspan="2" class="list-bottom-bg">
              <table border="0" class="list" width="100%">
                <tr>
                  <td class="highlight">Earliest start</td>
                  <td>@task_info.earliest_start@&nbsp;</td>
                </tr>
                
                <tr>
                  <td class="highlight">Earliest finish</td>
                  <td>@task_info.earliest_finish@</td>
                </tr>
                
                <tr>
                  <td class="highlight">Latest start</td>
                  <td>@task_info.latest_start@</td>
                </tr>
                
                <tr>
                  <td class="highlight">Latest finish</td>
                  <td><b>@task_info.latest_finish@</b></td>
                </tr>

                <if @task_info.latest_finish@ ne @task_info.end_date@>
                  <tr>
                    <td class="highlight">Deadline</td>
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
            <th>Assignees</th>
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
                  <li><a href="@assignee_remove_self_url;noquote@">Remove myself</a></li>
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
            <th colspan="2">Logger</th>
            <th align="right" valign="top" width="10">
              <img src="resources/tr-e6e6fa" align="top" />
            </th>
          </tr>
          
          <tr class="list-filter-header">
            <td class="list-bottom-bg" align="center" colspan="3">
	        Priority: @task_info.priority@<br />
              <if @use_days_p@ true>
                Days remaining: @task_info.days_remaining@<br />
              </if>
              <else>
                Hours remaining: @task_info.hours_remaining@<br />
              </else>
              <if @task_info.slack_time@ nil>
                Slack: n/a
              </if>
              <elseif @task_info.slack_time@ lt 1>
                Slack: <font color="red">@task_info.slack_time@</font><br />
              </elseif>
              <else>
                Slack: @task_info.slack_time@<br />
              </else>

              Complete: @task_info.percent_complete@%
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
            <th>@task_term@s this depends on.</th>
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
            <th>@task_term@s depending on this @task_term@</th>
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
            <th>Related @task_term@s</th>
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
                Link task: 
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
  
    
