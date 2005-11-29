<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @show_alert_p@>
    <br>
    #project-manager.close_warning#
    <br>
    <br>
    <formtemplate id="alert"></formtemplate>
</if>