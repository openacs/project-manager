<!-- Navigation bar -->
<table class="logger_navbar" width="100%">
    <tr>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="logger_navbar">
              <multiple name="links">
              <if @links.rownum@ gt 1>&nbsp;|&nbsp;</if>
              <if @links.selected_p@><i></if>
              <a href="@links.url@" class="logger_navbar">@links.name@</a>
              <if @links.selected_p@></i></if>
              </multiple>
              &nbsp;&nbsp;
            </td>
          </tr>
        </table>
      </td>
    </tr>
</table>
