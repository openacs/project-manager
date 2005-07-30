<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/people.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-01 -->
<!-- @arch-tag: cb6d4744-1947-49b7-a3ab-a9f25a383956 -->
<!-- @cvs-id $Id$ -->

<queryset>
    <fullquery name="assignees">
    <querytext>
    select distinct
    p.first_names || ' ' || p.last_name as name,
    p.person_id as party_id
    FROM
    persons p,
    pm_project_assignment pa
    WHERE
    p.person_id = pa.party_id 
    $users_clause

    </querytext>
  </fullquery>

</queryset>