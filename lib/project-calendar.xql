<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/project-manager/lib/people.xql -->
<!-- @author Malte Sussdorff (sussdorff@sussdorff.de) -->
<!-- @creation-date 2005-05-01 -->
<!-- @arch-tag: cb6d4744-1947-49b7-a3ab-a9f25a383956 -->
<!-- @cvs-id $Id$ -->

<queryset>
    <fullquery name="community_members">
    <querytext>
    select
    p.first_names || ' ' || p.last_name as name,
    p.person_id as party_id
    FROM
    persons p,
    acs_rels r,
    membership_rels mr
    WHERE
    r.object_id_one = :community_id and
    mr.rel_id = r.rel_id and
    p.person_id = r.object_id_two and
    member_state = 'approved'
    ORDER BY
    p.first_names, p.last_name

    </querytext>
  </fullquery>

    <fullquery name="dotlrn_members">
    <querytext>
    select
    du.first_names || ' ' || du.last_name as name,
    du.user_id as party_id
    FROM
    dotlrn_users du
    </querytext>
  </fullquery>

</queryset>