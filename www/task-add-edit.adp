<master src="lib/master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context@</property>
  
  
  <center>
    <form action="task-add-edit-2" method="post">
      @export_vars;noquote@ 
      
      <span class="selected">
        Send email to assignees? 
        <select name="send_email_p" >
          <option value="t" selected="selected">Yes</option>
          <option value="f">No</option>
        </select>

        <if @using_process_p@ true>
          Process name <input type="text" name="process_name" size="25" value="@process_name@" />
        </if>
      </span>

      <table border="0" cellpadding="0" cellspacing="0">
        
        <multiple name="tasks">

          <tr bgcolor="#9999cc">
            <td align="left" valign="top" width="10">
              <img src="resources/tl-9999cc.jpg" />
            </td>
            
            <td colspan="2">
              <if @edit_p@ true>
                @task_term_lower;noquote@ &nbsp;@tasks.task_item_id@
              </if>
              <else>
                @task_term_lower;noquote@ &nbsp;@tasks.rownum@
              </else>
            </td>
            
            <td align="right" valign="top" width="10">
              <img src="resources/tr-9999cc.jpg" />
            </td>
            
          </tr>
          
          <if @tasks.rownum@ odd>
            <tr bgcolor="#e6e6fa">
          </if>
          <else>
            <tr bgcolor="#ddffdd">
          </else>

          <td rowspan="2" align="center" valign="top">
            <input type="hidden" name="task_item_id.@tasks.rownum@" value="@tasks.task_item_id@" />
            <input type="hidden" name="number" value="@tasks.rownum@" />
          </td>

          <td valign="top"><b>Subject:</b><font color="red">*</font><br /><input type="text" size="39" name="task_title.@tasks.rownum;noquote@" value="@tasks.one_line@"><p />

              <b>Description:</b><br />
              <textarea name="description.@tasks.rownum;noquote@" rows="14" cols="40" id="richtext__add_edit__description.@tasks.rownum;noquote@">@tasks.description@</textarea><br />

              Format: 
              <select name="description_mime_type.@tasks.rownum;noquote@" id="richtext__add_edit__description.@tasks.rownum@">
                
                <if @tasks.description_mime_type@ eq "text/enhanced">
                  <option value="text/enhanced" selected="selected">Enhanced Text</option>
                </if>
                <else>
                  <option value="text/enhanced">Enhanced Text</option>
                </else>

                <if @tasks.description_mime_type@ eq "text/plain">
                  <option value="text/plain" selected="selected">Plain Text</option>
                </if>
                <else>
                  <option value="text/plain">Plain Text</option>
                </else>

                <if @tasks.description_mime_type@ eq "text/fixed-width">
                  <option value="text/fixed-width" selected="selected">Fixed-width Text</option>
                </if>
                <else>
                  <option value="text/fixed-width">Fixed-width Text</option>
                </else>

                <if @tasks.description_mime_type@ eq "text/html">
                  <option value="text/html" selected="selected">HTML</option>
                </if>
                <else>
                  <option value="text/html">HTML</option>
                </else>
              </select>

              <if @edit_p@ true>

                <p />
                <b>Comment</b><br />
                <textarea name="comments.@tasks.rownum;noquote@" rows="7" cols="40"></textarea><br />

                Format: 
                <select name="comments_mime_type.@tasks.rownum;noquote@">
                  <option value="text/enhanced">Enhanced Text</option>
                  <option value="text/plain" selected="selected">Plain Text</option>
                  <option value="text/fixed-width">Fixed-width Text</option>
                  <option value="text/html">HTML</option>
                </select>
                
              </if>
              <else>
                <input type="hidden" name="comments.@tasks.rownum@" value="" />
                <input type="hidden" name="comments_mime_type.@tasks.rownum@" value="text/plain" />
              </else>

          </td>

        </td>
          
          <td width="15">&nbsp;</td>

          <td valign="top">
            <table border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td><b>Work required:</b><font color="red">*</font></td>
              </tr>

              <if @use_day_p@ true>
                <if @use_uncertain_completion_times_p@ eq 1>
                  <tr><td>Min:</td>
                    <td><input type="text" name="estimated_days_work_min.@tasks.rownum;noquote@" size="5" value="@tasks.work_min_days@"> @work_units;noquote@</td>
                  </tr>
                  
                  <tr><td>Max:</td>
                    <td><input type="text" name="estimated_days_work_max.@tasks.rownum;noquote@" size="5" value="@tasks.work_max_days@"> @work_units;noquote@</td>
                  </tr>
                </if>

                <else>
                  <tr><td><input type="text" name="estimated_hours_work.@tasks.rownum;noquote@" size="5" value="@tasks.work_hrs@"> @work_units;noquote@</tr>
                </else>
              </if>
              <else>
                <if @use_uncertain_completion_times_p@ eq 1>
                  <tr><td>Min:</td>
                    <td><input type="text" name="estimated_hours_work_min.@tasks.rownum;noquote@" size="5" value="@tasks.work_min_hrs@"> @work_units;noquote@</td>
                  </tr>
                  
                  <tr><td>Max:</td>
                    <td><input type="text" name="estimated_hours_work_max.@tasks.rownum;noquote@" size="5" value="@tasks.work_max_hrs@"> @work_units;noquote@</td>
                  </tr>
                </if>
                <else>
                  <tr><td><input type="text" name="estimated_hours_work.@tasks.rownum;noquote@" size="5" value="@tasks.work_hrs@"> @work_units;noquote@</tr>
                </else>
              </else>
            </table>
            
            <p />
          
            <div class="shaded">

              Deadline: @tasks.end_date_html;noquote@</p>

              <input type="hidden" name="process_task_id.@tasks.rownum@" value="@tasks.process_task_id;noquote@" />

              <p />

              @tasks.project_html;noquote@
              
              <p />

              Dependency: <br />
              <select name="dependency.@tasks.rownum@">
                @tasks.dependency_html;noquote@
              </select>

              <p />

	        Priority:
		<input type="text" name="priority.@tasks.rownum@" value="@tasks.priority@" size="4"/>
		<br />
		<span style="margin-top: 4px; margin-bottom: 2px; color:
                  #666666; font-family:
                  tahoma,verdana,arial,helvetica,sans-serif; font-size:
                  75%;">
                  <img src="/shared/images/info.gif" width="12"
                    height="9" alt="[i]" title="Help text" border="0">
                    Enter a number for ordering the priority. 0 is the default
		and also the lowest priority.
                </span>
		<p />

              <if @edit_p@ true>
		Status:
                <input type="text" name="percent_complete.@tasks.rownum@" value="@tasks.percent_complete@" size="4"/>
                %<br />
                <span style="margin-top: 4px; margin-bottom: 2px; color:
                  #666666; font-family:
                  tahoma,verdana,arial,helvetica,sans-serif; font-size:
                  75%;">
                  <img src="/shared/images/info.gif" width="12"
                    height="9" alt="[i]" title="Help text" border="0">
                    Enter 100% to close the @task_term_lower@, or less to open it.
                </span>
              </if>
              <elseif @using_process_p@ true>
                Status: 
                <select name="percent_complete.@tasks.rownum@">
                  <option value="0">Open</option>
                  <option value="100">Closed</option>
                </select>
              </elseif>
              <else>
                <input type="hidden" name="percent_complete.@tasks.rownum@" value="0" />
              </else>
              

              <p />

              <if @edit_p@ true>
                <p />
                Log entry:
                <table border="0" class="list">
                  <tr class="form-element">
                    <td class="form-label">Quantity:</td>
                    <td class="form-widget">
                      <input type="text" name="hours.@tasks.rownum@"
                        size="4" />
                      @tasks.logger_variable_html;noquote@
                    </td>
                  </tr>

                  <tr class="form-element">
                    <td class="form-label">Date:</td>
                    <td class="form-widget">
                      <%= [set today_html@tasks.task_item_id@] %>
                    </td>
                  </tr>

                  <tr class="form-element">
                    <td class="form-label">Description:</td>
                    <td class="form-widget">
                      <input type="text"
                        name="log.@tasks.rownum@" size="30" />
                    </td>
                  </tr>
                  
                  <tr class="form-element">
                    <td>
                      <td class="form-widget">
                        <p style="margin-top: 4px; margin-bottom: 2px;
                    color: #666666; font-family:
                    tahoma,verdana,arial,helvetica,sans-serif;
                    font-size: 75%;">
                          <img src="/shared/images/info.gif"
                    width="12" height="9" alt="[i]" title="Help text"
                    border="0">
                            You can optionally log time worked here.
                        </p>
                      </td>
                  </tr>
                </table>

              </if>

          </td>
          
        </tr>
          
          <if @tasks.rownum@ odd>
            <tr bgcolor="lavender">
          </if>
          <else>
            <tr bgcolor="#ddffdd">
          </else>
          
          <td colspan="3">@tasks.assignee_html;noquote@</td>

        </tr>

          <if @tasks.rownum@ odd>
            <tr bgcolor="#e6e6fa">
              <td align="left" valign="bottom" width="10">
                <img src="resources/bl-e6e6fa.jpg" />
              </td>
              
              <td colspan="2">&nbsp;</td>
              
              <td align="right" valign="bottom" width="10">
                <img src="resources/br-e6e6fa.jpg" />
              </td>
          </if>
          <else>
            <tr bgcolor="#ddffdd">
              <td align="left" valign="bottom" width="10">
                <img src="resources/bl-ddffdd.jpg" />
              </td>
              
              <td colspan="2">&nbsp;</td>
              
              <td align="right" valign="bottom" width="10">
                <img src="resources/br-ddffdd.jpg" />
              </td>
          </else>

          <tr bgcolor="#ffffff">
            <td colspan="4">&nbsp;</td>
          </tr>
        </multiple>

        <input type="hidden" name="process_id" value="@process_id;noquote@" />
        <tr>
          <td colspan="5" align="center"><input type="submit" name="formbutton:ok" value = "       OK       "></td>
        </tr>
      </form>
    </table>
  </center>

    <table border="0" cellpadding="5" cellspacing="0" class="list">
