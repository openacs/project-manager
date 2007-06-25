    <if @filter_p@ eq 1>
        <div id="search-block">
        <form method=post name=search action=index>
          <b>#project-manager.Search#</b>
          <input type=text name=searchterm value="@searchterm@" size="15" />
          @hidden_vars;noquote@
          #project-manager.Start_date#:
          <input type=text name="start_range_f" value="@start_range_f@" id="sel1" size="10"/>
          <input type='reset' value='...' onclick="return showCalendar('sel1', 'y-m-d');">
	  #project-manager.End_date#:
          <input type=text name="end_range_f" value="@end_range_f@" id="sel2" size="10"/>
          <input type='reset' value='...' onclick="return showCalendar('sel2', 'y-m-d');">
          <input type="submit" value="#project-manager.search#" />
          </div>
        </form>
<br />
   <div id="search-block-big">    
	<multiple name="projects">
             @projects.category_select;noquote@
        </multiple>
	<listfilters name=projects style="select-menu"></listfilters>
    </div>
      </if>
    <listtemplate name=projects></listtemplate>


