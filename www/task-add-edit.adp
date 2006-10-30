<master src="lib/master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context@</property>
  
  
  <center>
    <form action="task-add-edit-2" method="post">
      @export_vars;noquote@ 
      
      <span class="selected">
        #project-manager.lt_Send_email_to_assigne# 
        <select name="send_email_p" >
          <option value="t" selected="selected">#project-manager.Yes#</option>
          <option value="f">#project-manager.No#</option>
        </select>

        <if @using_process_p@ true>
          #project-manager.Process_name# <input type="text" name="process_name" size="25" value="@process_name@" />
        </if>
      </span>

      <table border="0" cellpadding="0" cellspacing="0">
        
        <multiple name="tasks">

          <tr bgcolor="#9999cc">
            <td align="left" valign="top" width="10">
              <img src="/resources/project-manager/tl-9999cc.jpg" />
            </td>
            
            <td colspan="2">
              <if @edit_p@ true>
                @task_term_lower;noquote@ &nbsp;@tasks.task_item_id@:@tasks.one_line@
              </if>
              <else>
                @task_term_lower;noquote@ &nbsp;@tasks.rownum@
              </else>
            </td>
            
            <td align="right" valign="top" width="10">
              <img src="/resources/project-manager/tr-9999cc.jpg" />
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

          <td valign="top"><b>#project-manager.Subject#</b><font color="red">*</font><br /><input type="text" size="39" name="task_title.@tasks.rownum;noquote@" value="@tasks.one_line@"><p />

              <b>#project-manager.Description_1#</b><br />
              <textarea name="description.@tasks.rownum;noquote@" rows="14" cols="40" id="richtext__add_edit__description.@tasks.rownum;noquote@">@tasks.description@</textarea><br />

              #project-manager.Format# 
              <select name="description_mime_type.@tasks.rownum;noquote@" id="richtext__add_edit__description.@tasks.rownum@">
                
                <if @tasks.description_mime_type@ eq "text/enhanced">
                  <option value="text/enhanced" selected="selected">#project-manager.Enhanced_Text#</option>
                </if>
                <else>
                  <option value="text/enhanced">#project-manager.Enhanced_Text#</option>
                </else>

                <if @tasks.description_mime_type@ eq "text/plain">
                  <option value="text/plain" selected="selected">#project-manager.Plain_Text#</option>
                </if>
                <else>
                  <option value="text/plain">#project-manager.Plain_Text#</option>
                </else>

                <if @tasks.description_mime_type@ eq "text/fixed-width">
                  <option value="text/fixed-width" selected="selected">#project-manager.Fixed-width_Text#</option>
                </if>
                <else>
                  <option value="text/fixed-width">#project-manager.Fixed-width_Text#</option>
                </else>

                <if @tasks.description_mime_type@ eq "text/html">
                  <option value="text/html" selected="selected">#project-manager.HTML#</option>
                </if>
                <else>
                  <option value="text/html">#project-manager.HTML#</option>
                </else>
              </select>

              <if @edit_p@ true>

                <p />
                <b>#project-manager.Comment_1#</b><br />
                <textarea name="comments.@tasks.rownum;noquote@" rows="7" cols="40"></textarea><br />

                #project-manager.Format# 
                <select name="comments_mime_type.@tasks.rownum;noquote@">
                  <option value="text/enhanced">#project-manager.Enhanced_Text#</option>
                  <option value="text/plain" selected="selected">#project-manager.Plain_Text#</option>
                  <option value="text/fixed-width">#project-manager.Fixed-width_Text#</option>
                  <option value="text/html">#project-manager.HTML#</option>
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
                <td><b>#project-manager.Work_required#</b><font color="red">*</font></td>
              </tr>

              <if @use_day_p@ true>
                <if @use_uncertain_completion_times_p@ eq 1>
                  <tr><td>#project-manager.Min#</td>
                    <td><input type="text" name="estimated_days_work_min.@tasks.rownum;noquote@" size="5" value="@tasks.work_min_days@"> @work_units;noquote@</td>
                  </tr>
                  
                  <tr><td>#project-manager.Max#</td>
                    <td><input type="text" name="estimated_days_work_max.@tasks.rownum;noquote@" size="5" value="@tasks.work_max_days@"> @work_units;noquote@</td>
                  </tr>
                </if>

                <else>
                  <tr><td><input type="text" name="estimated_hours_work.@tasks.rownum;noquote@" size="5" value="@tasks.work_hrs@"> @work_units;noquote@</tr>
                </else>
              </if>
              <else>
                <if @use_uncertain_completion_times_p@ eq 1>
                  <tr><td>#project-manager.Min#</td>
                    <td><input type="text" name="estimated_hours_work_min.@tasks.rownum;noquote@" size="5" value="@tasks.work_min_hrs@"> @work_units;noquote@</td>
                  </tr>
                  
                  <tr><td>#project-manager.Max#</td>
                    <td><input type="text" name="estimated_hours_work_max.@tasks.rownum;noquote@" size="5" value="@tasks.work_max_hrs@"> @work_units;noquote@</td>
                  </tr>
                </if>
                <else>
                  <tr><td><input type="text" name="estimated_hours_work.@tasks.rownum;noquote@" size="5" value="@tasks.work_hrs@"> @work_units;noquote@</tr>
                </else>
              </else>
            </table>
            
            <p />
          
            

              #project-manager.lt_Deadline_tasksend_dat#</p>

              <input type="hidden" name="process_task_id.@tasks.rownum@" value="@tasks.process_task_id;noquote@" />

              <p />

              @tasks.project_html;noquote@
              
              <p />

              #project-manager.Dependency# <br />
              <select name="dependency.@tasks.rownum@">
                @tasks.dependency_html;noquote@
              </select>

              <p />

	        #project-manager.Priority#
		<input type="text" name="priority.@tasks.rownum@" value="@tasks.priority@" size="4"/>
		<br />
		<span style="margin-top: 4px; margin-bottom: 2px; color:
                  #666666; font-family:
                  tahoma,verdana,arial,helvetica,sans-serif; font-size:
                  75%;">
                  <img src="/resources/acs-subsite/info.gif" width="12"
                    height="9" alt="[i]" title="Help text" border="0">
                    #project-manager.lt_Enter_a_number_for_or#
                </span>
		<p />

              <if @edit_p@ true>
		#project-manager.Status#
                <input type="text" name="percent_complete.@tasks.rownum@" value="@tasks.percent_complete@" size="4"/>
                %<br />
                <span style="margin-top: 4px; margin-bottom: 2px; color:
                  #666666; font-family:
                  tahoma,verdana,arial,helvetica,sans-serif; font-size:
                  75%;">
                  <img src="/resources/acs-subsite/info.gif" width="12"
                    height="9" alt="[i]" title="Help text" border="0">
                    #project-manager.lt_Enter_100_to_close_th_1#
                </span>
              </if>
              <elseif @using_process_p@ true>
                #project-manager.Status# 
                <select name="percent_complete.@tasks.rownum@">
                  <option value="0">#project-manager.Open#</option>
                  <option value="100">#project-manager.Closed#</option>
                </select>
              </elseif>
              <else>
                <input type="hidden" name="percent_complete.@tasks.rownum@" value="0" />
              </else>
              

              <p />

              <if @edit_p@ true>
                <p />
                #project-manager.Log_entry#
                <table border="0" class="list">
                  <tr class="form-element">
                    <td class="form-label">#project-manager.Quantity#</td>
                    <td class="form-widget">
                      <input type="text" name="hours.@tasks.rownum@"
                        size="4" />
                      @tasks.logger_variable_html;noquote@
                    </td>
                  </tr>

                  <tr class="form-element">
                    <td class="form-label">#project-manager.Date_1#</td>
                    <td class="form-widget">
                      <%= [set today_html@tasks.task_item_id@] %>
                    </td>
                  </tr>

                  <tr class="form-element">
                    <td class="form-label">#project-manager.Description_1#</td>
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
                          <img src="/resources/acs-subsite/info.gif"
                    width="12" height="9" alt="[i]" title="Help text"
                    border="0">
                            #project-manager.lt_You_can_optionally_lo#
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
                <img src="/resources/project-manager/bl-e6e6fa.jpg" />
              </td>
              
              <td colspan="2">&nbsp;</td>
              
              <td align="right" valign="bottom" width="10">
                <img src="/resources/project-manager/br-e6e6fa.jpg" />
              </td>
          </if>
          <else>
            <tr bgcolor="#ddffdd">
              <td align="left" valign="bottom" width="10">
                <img src="/resources/project-manager/bl-ddffdd.jpg" />
              </td>
              
              <td colspan="2">&nbsp;</td>
              
              <td align="right" valign="bottom" width="10">
                <img src="/resources/project-manager/br-ddffdd.jpg" />
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

