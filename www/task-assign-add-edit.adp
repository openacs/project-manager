<master src="lib/master">
  <property name="context">@context@</property>
  <property name="title">@title@</property>
  

  <center>

    <formtemplate id="add_edit" style="standard-lars">

      <multiple name="tasks">

        <table width="100%" border="0" cellpadding="3" cellspacing="0">
          <tr>
            <th colspan="2" bgcolor="lavender">@tasks.one_line@</th>
          </tr>

          <tr>

            <td>
              <multiple name="num">
                <formwidget id="party_id.@tasks.item_id@.@num.number@">
                  <formerror id="party_id.@tasks.item_id@.@num.number@">
                  </formerror>
                </formwidget>

                <formwidget id="role_id.@tasks.item_id@.@num.number@">
                  <formerror
                    id="role_id.@tasks.item_id@.@num.number@">
                    </formerror>
                  </formwidget>

                <br />
              </multiple>
            </td>
          </tr>

        </table>

      </multiple>
      
      <P />

      <formwidget id="formbutton:ok" />
        
    </formtemplate>
  </table>
  </center>


