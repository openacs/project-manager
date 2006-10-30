<!-- Log entries table start -->

<if @entries:rowcount@ eq 0>
  <span class="no_items_text">#project-manager.lt_There_are_no_matching#</span>
</if>
<else>
  <table class="logger_listing_tiny" cellpadding="3" cellspacing="1" width="100%">
    <tr class="logger_listing_header">
      <th class="logger_listing_narrow">&nbsp;</th>
      <th class="logger_listing_narrow">#project-manager.Task#</th>  
      <th class="logger_listing_narrow">#project-manager.User#</th>  
      <th class="logger_listing_narrow">#project-manager.Date#</th>
      <th class="logger_listing_narrow">@variable.name@</th>
      <th class="logger_listing_narrow">#project-manager.Description#</th>
      <th class="logger_listing_narrow">&nbsp;</th>
    </tr>

    <if @group_by@ not nil>
      <multiple name="entries">
        <tr class="logger_listing_spacer">
          <td colspan="7">
            &nbsp;
          </td>
        </tr>
        <tr class="logger_listing_subheader">
          <td colspan="7">
            <switch @group_by@>
              <case value="user_id">
                #project-manager.User#: @entries.user_chunk;noquote@
              </case>
              <case value="project_name">
                #project-manager.Project#: @entries.project_name@
              </case>
              <case value="time_stamp">
                #project-manager.Date#: @entries.time_stamp_pretty@
              </case>
              <case value="time_stamp_week">
                #project-manager.Week#: @entries.time_stamp_week@
              </case>
              <default>
                #project-manager.lt_Unknown_group_by_colu#
              </default>
            </switch>
          </td>
        </tr>
        <group column="@group_by@">
          <if @entries.selected_p@ true>
              <tr class="logger_listing_subheader">
          </if>
          <else>
            <if @entries.rownum@ odd>
              <tr class="logger_listing_odd">
            </if>
            <else>
              <tr class="logger_listing_even">
            </else>
          </else>
            <td class="logger_listing_narrow">
              <if @entries.edit_p@ or @current_user_id@ eq @entries.user_id@>
                <a href="@entries.edit_url@" title="Edit this log entry"><img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
              </if>
            </td>
            <td class="logger_listing_narrow">@entries.project_name@</td>
            <td class="logger_listing_narrow">@entries.user_chunk;noquote@</td>
            <td class="logger_listing_narrow" align="left">@entries.time_stamp_pretty@</td>
            <td class="logger_listing_narrow" align="right" nowrap>
              <a href="@entries.view_url@" title="View this log entry">@entries.value@</a>
            </td>
            <td class="logger_listing_narrow">
              @entries.description@
            </td>
            <td class="logger_listing_narrow">
              <if @entries.delete_url@ not nil>
                <a href="@entries.delete_url@" onclick="@entries.delete_onclick@" title="Delete this log entry"><img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
              </if>
            </td>
          </tr>
          <if @entries.groupnum_last_p@ true>
            <tr class="logger_listing_subheader">
              <td class="logger_listing_narrow" align="center">&nbsp;</td>
              <td class="logger_listing_narrow" colspan="3">
                <if @variable.type@ eq "additive">
                  <b>#project-manager.Subtotal#</b>
                </if>
                <else>
                  <b>#project-manager.Subtotal_Average#</b>
                </else>
              </td>
              <td class="logger_listing_narrow" align="right" nowrap>
                <if @variable.type@ eq "additive">
                  <b>@entries.subtotal@</b>
                </if>
                <else>
                  <b>@entries.subaverage@</b>
                </else>
              </td>
              <td class="logger_listing_narrow">&nbsp;</td>
              <td class="logger_listing_narrow" align="center">&nbsp;</td>
            </tr>
          </if>
        </group>
      </multiple>
    </if>
  <else>
    <multiple name="entries">
      <if @entries.selected_p@ true>
          <tr class="logger_listing_subheader">
      </if>
      <else>
        <if @entries.rownum@ odd>
          <tr class="logger_listing_odd">
        </if>
        <else>
          <tr class="logger_listing_even">
        </else>
      </else>
        <td class="logger_listing_narrow">
          <if @entries.edit_p@ or @current_user_id@ eq @entries.user_id@>
            <a href="@entries.edit_url@" title="Edit this log entry"><img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
          </if>
        </td>
        <td class="logger_listing_narrow">@entries.project_name@</td>
        <td class="logger_listing_narrow">@entries.user_chunk;noquote@</td>
        <td class="logger_listing_narrow" align="left">@entries.time_stamp_pretty@</td>
        <td class="logger_listing_narrow" align="right" nowrap>
          <if @entries.edit_p@ or @current_user_id@ eq @entries.user_id@>
            <a href="@entries.view_url@" title="View this log entry">@entries.value@</a>
          </if>
          <else>
            <a href="@entries.view_url@" title="View this log entry">@entries.value@</a>
          </else>
        </td>
        <td class="logger_listing_narrow">
          @entries.description@
        </td>
        <td class="logger_listing_narrow">
          <if @entries.delete_url@ not nil>
            <a href="@entries.delete_url@" onclick="@entries.delete_onclick@" title="Delete this log entry"><img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a>
          </if>
        </td>
      </tr>
    </multiple>
  </else>

    <!-- Row for the grand total -->
    <tr class="logger_listing_spacer">
      <td colspan="7">
        &nbsp;
      </td>
    </tr>
    <tr class="logger_listing_subheader">
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
      <td class="logger_listing_narrow" colspan="3">
        <if @variable.type@ eq "additive">
          <b>#project-manager.Total#</b>
        </if>
        <else>
          <b>#project-manager.Average#</b>
        </else>
      </td>
      <td class="logger_listing_narrow" align="right" nowrap>
        <if @variable.type@ eq "additive">
          <if @projection_value@ not nil and @value_total@ gt @projection_value@>
            <font color="red"><b>@value_total@</b></font>
          </if>
          <else>
            <b>@value_total@</b>
          </else>
        </if>
        <else>
          <if @projection_value@ not nil and @value_average@ gt @projection_value@>
            <font color="red"><b>@value_average@</b></font>
          </if>
          <else>
            <b>@value_average@</b>
          </else>
        </else>
      </td>
      <td class="logger_listing_narrow">&nbsp;</td>
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
    </tr>

    <!-- Row for projected value -->
  <if @projection_value@ not nil>
    <tr class="logger_listing_spacer">
      <td colspan="7">
        &nbsp;
      </td>
    </tr>
    <tr class="logger_listing_odd">
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
      <td class="logger_listing_narrow" colspan="3"><b>#project-manager.Projection#</b></td>
      <td class="logger_listing_narrow" align="right" nowrap><b>@projection_value@</b></td>
      <td class="logger_listing_narrow">&nbsp;</td>
      <td class="logger_listing_narrow" align="center">&nbsp;</td>
    </tr>
  </if>

  <!-- Unit -->
  <tr class="logger_listing_even">
    <th class="logger_listing_narrow">&nbsp;</th>
    <th class="logger_listing_narrow">&nbsp;</th>  
    <th class="logger_listing_narrow">&nbsp;</th>  
    <th class="logger_listing_narrow">&nbsp;</th>
    <th class="logger_listing_narrow">@variable.unit@</th>
    <th class="logger_listing_narrow">&nbsp;</th>
    <th class="logger_listing_narrow">&nbsp;</th>
  </tr>

  </table>
</else>

<!-- Log entries table end -->

