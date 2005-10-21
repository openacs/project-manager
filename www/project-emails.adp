<master>
  <property name="title">@title@</property>
  <property name="context">@context;noquote@</property>
  
    <p />
	<if @mt_installed_p@>
	    <include src="/packages/project-manager/lib/mail-portlet" project_item_id=@project_item_id@ page=@page@>
	</if>
    <p />
  
  
