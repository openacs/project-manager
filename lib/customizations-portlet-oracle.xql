<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/customizations-portlet-oracle.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-02 -->
<!-- @arch-tag: 572536be-f753-45cf-82d6-a853c9ca3902 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>
  
    <fullquery name="custom_query">
    <querytext>
        SELECT  p.customer_id,
                c.name as customer_name
        FROM    pm_projectsx p ,
                organizations c 
        WHERE p.customer_id = c.organization_id (+)  and 
        p.project_id = :original_project_id
        and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = :original_project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
    </querytext>
  </fullquery>

</queryset>