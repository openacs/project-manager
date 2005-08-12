<master src=lib/master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<b>#project-manager.Move_task_to#</b>
<formtemplate id="move_task"></formtemplate>

<if @search_p@>
   <b>#project-manager.Results#</b>
   <formtemplate id="move_task_search"></formtemplate>
</if>
<else>
   <b>#project-manager.or_search_for#</b>
   <formtemplate id="search_projects"></formtemplate>
</else>

