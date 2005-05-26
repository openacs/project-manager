<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/tcl/project-manager-procs.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-01 -->
<!-- @arch-tag: 87104698-5137-4113-b324-cf15c097811d -->
<!-- @cvs-id $Id$ -->

<queryset>
  <fullquery name="pm::util::get_project_name_not_cached.get_project_name">
    <querytext>
      select p.title as project_name
  	FROM
	pm_projectsx p
	WHERE
        project_id = :project_id
    </querytext>
  </fullquery>
  <fullquery name="pm::util::get_parent_id_not_cached.get_project_name">
    <querytext>
      select p.parent_id
  	FROM
	pm_projectsx p
	WHERE
	p.item_id    = :project_item_id and
        p.project_id = :project_id
    </querytext>
  </fullquery>

</queryset>