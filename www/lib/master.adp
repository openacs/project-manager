<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>
<property name="header_stuff">
  @header_stuff;noquote@
    <style type="text/css">   <link rel="stylesheet" type="text/css" href="/resources/project-manager/style.css" />
   </style>
  </property>
<property name="doc_type">
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
</property>
<property name="navbar_list">@navbar_list@</property>
<style type="text/css">
td.highlighted {
  background-color:#ddddff;
  font: 90% Verdana,Georgia,Serif;
}

td.highlight {
  background-color:#ffffdd;
  border-bottom: 1px dotted #A0BDEB;
  font: 90% Verdana,Georgia,Serif;
}

td.subheader {
  background-color:#ffffdd;
  border-top: 1px dotted #e6e6fa;
  border-bottom: 1px dotted #e6e6fa;
  border-left: 1px solid #e6e6fa;
  font: 90% Verdana,Georgia,Serif;
}

td.list-bg {
  border-left: 1px solid #e6e6fa;
  font: 90% Verdana,Georgia,Serif;
}

td.list-bottom-bg {
  border-bottom: 1px solid #e6e6fa;
  border-left: 1px solid #e6e6fa;
  font: 90% Verdana,Georgia,Serif;
}

td.list-right-bg {
  border-bottom: 1px solid #e6e6fa;
  border-right: 1px solid #e6e6fa;
  font: 90% Verdana,Georgia,Serif;
}

th.project {
        background-color:#9999cc;
  font: 90% Verdana,Georgia,Serif;
}

td.project-filter-pane {
        background-color: #bbbbee;
        vertical-align: top;
  font: 90% Verdana,Georgia,Serif;
}

.shaded {
        background-color: #dddddd;
}

.selected {
        background-color: #eeccdd;
}

th { 
     font-size: 9pt;
     text-align: left;
     background-color:dfdfff;
}


/* From logger */

table.logger_navbar {
  background-color: #41329c;
  clear: both;
}
a.logger_navbar { 
    color: white; 
    text-decoration: none;
}
a.logger_navbar:visited { 
  color: white; 
}
a.logger_navbar:hover { 
    color: white; 
    text-decoration: underline;
}
td.logger_navbar {
  font-family: tahoma,verdana,arial,helvetica; 
  font-size: 70%; 
  font-weight: bold; 
  color: #ccccff; 
  text-decoration: none; 
  font: 90% Verdana,Georgia,Serif;
}

td.fill-list-right {
  border-bottom: 3px solid #A0BDEB;
  border-right: 1px solid #A0BDEB;
  background-color: #eaf2ff;
  font: 90% Verdana,Georgia,Serif;
}

td.fill-list-right2 {
  border-right: 1px solid #A0BDEB;
  background-color: #eaf2ff;
  font: 90% Verdana,Georgia,Serif;
}

td.fill-list-bottom {
  border-bottom: 3px solid #A0BDEB;
  border-left: 1px solid #A0BDEB;
  background-color: #eaf2ff;
  font: 90% Verdana,Georgia,Serif;
}

td.fill-list-middle {
  border-left: 1px solid #A0BDEB;
  background-color: #eaf2ff;
  font: 90% Verdana,Georgia,Serif;
}

td.fill-list-bg {
  background-color: #eaf2ff;
  font: 90% Verdana,Georgia,Serif;
}

#pm_lead {
  color: green;
}

#search-block { 
  border:1px solid #000; 
  background-color: #EAF2FF;
  padding:5px; 
  width:70%;
}

#search-block-big { 
  border:1px solid #000; 
  background-color: #EAF2FF;
  padding:5px; 
  width:99%;
}

h3 {
  background-color:#ffffdd;
  font: 100% Verdana,Georgia,Serif;
}
</style>

<!-- include src="nav-bar" project_item_id="@project_item_id@" -->
<p />

<slave>

<p />
<include src="nav-bar" project_item_id="@project_item_id@">


