<master src="lib/master">
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="title">@title@</property>


  <center>

    <table border="1" cellpadding="5" cellspacing="0">
      <form action="process-task-add-edit-2" method="post">
        <multiple name="num">

          <if @num.rownum@ odd>
            <tr bgcolor="lavender">
          </if>
          <else>
            <tr bgcolor="#ddffdd">
          </else>

          <td rowspan="2" align="center">&nbsp;@num.rownum@&nbsp;&nbsp;</td>

          <td valign="top"><b>#project-manager.Subject#</b><font color="red">*</font><br /><input type="text" size="39" name="task_title.@num.rownum;noquote@" value="@num.one_line@"><p />

              <b>#project-manager.Description_1#</b><br />
              <textarea name="description.@num.rownum;noquote@" rows="14" cols="40">@num.description@</textarea></td>

        </td>

          <td valign="top">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
              <tr>
                <td><b>#project-manager.Work_required#</b><font color="red">*</font></td>
              </tr>

              <if @use_day_p@ true>
                <if @use_uncertain_completion_times_p@ eq 1>
                  <tr><td>#project-manager.Min#</td>
                    <td><input type="text" name="estimated_days_work_min.@num.rownum;noquote@" size="5" value="@num.work_days_min@"> #project-manager.days#</td>
                  </tr>
                  
                  <tr><td>#project-manager.Max#</td>
                    <td><input type="text" name="estimated_days_work_max.@num.rownum;noquote@" size="5" value="@num.work_days_max@"> #project-manager.days#</td>
                  </tr>
                </if>
                <else>
                  <tr><td><input type="text" name="estimated_days_work.@num.rownum;noquote@" size="5" value="@num.work_days@"> #project-manager.days#</tr>
                </else>
                
              </if>
              <else>
                <if @use_uncertain_completion_times_p@ eq 1>
                  <tr><td>#project-manager.Min#</td>
                    <td><input type="text" name="estimated_hours_work_min.@num.rownum;noquote@" size="5" value="@num.work_min@"> #project-manager.hrs#</td>
                  </tr>
                  
                  <tr><td>#project-manager.Max#</td>
                    <td><input type="text" name="estimated_hours_work_max.@num.rownum;noquote@" size="5" value="@num.work_max@"> #project-manager.hrs#</td>
                  </tr>
                </if>
                <else>
                  <tr><td><input type="text" name="estimated_hours_work.@num.rownum;noquote@" size="5" value="@num.work@"> #project-manager.hrs#</tr>
                </else>
                
              </else>

            </table>

            <p />

            <input type="checkbox" name="use_dependency.@num.rownum;noquote@" value="@num.process_task_id;noquote@" @num.checked@>
              #project-manager.lt_depends_on_another_ta#
              
              <p />

              <font size="-1">#project-manager.Order# <input type="text" name="ordering.@num.rownum;noquote@" size="5" value="@num.ordering;noquote@" /></font>


              <br />

              <input type="hidden" name="process_task_id" value="@num.process_task_id;noquote@" />
          </td>
          
        </tr>
          
          <if @num.rownum@ odd>
            <tr bgcolor="lavender">
          </if>
          <else>
            <tr bgcolor="#ddffdd">
          </else>
          
          <td colspan="2">@num.assignee_html;noquote@</td>

        </tr>
          
        </multiple>

        <input type="hidden" name="process_id" value="@process_id;noquote@" />
        <tr>
          <td colspan="99" align="center"><input type="submit" name="formbutton:ok" value = "       OK       "></td>
        </tr>
      </form>
    </table>
  </center>


