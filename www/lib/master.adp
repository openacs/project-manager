<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>
<property name="header_stuff">
  @header_stuff;noquote@
  <style type="text/css">
    @import url(@package_url@style.css) all;
  </style>
</property>
<property name="doc_type">
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
</property>

<style type="text/css">
   @import url(@package_url@style.css) all;
</style>

<include src="nav-bar" project_item_id="@project_item_id@">
<p />

<slave>

<p />
<include src="nav-bar" project_item_id="@project_item_id@">


