<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/customizations-portlet-postgresql.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-02 -->
<!-- @arch-tag: 8eecf794-bf8a-4375-ae49-cecf5eac81db -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>
  
    <fullquery name="custom_query">
    <querytext>
        SELECT
        p.customer_id,
        c.name as customer_name
        FROM
	pm_projectsx p 
        LEFT JOIN organizations c ON p.customer_id = c.organization_id 
        WHERE 
        p.project_id = :original_project_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :original_project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
    </querytext>
  </fullquery>

</queryset>