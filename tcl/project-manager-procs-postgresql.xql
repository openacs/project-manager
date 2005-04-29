<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-06-11 -->
<!-- @arch-tag: 9a0aca80-2974-4b08-a211-25482d8419b5 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.3</version>
  </rdbms>
  
  <fullquery name="pm::util::category_selects_not_cached.get_categories">
    <querytext>
    SELECT 
    t.name as cat_name, 
    t.category_id as cat_id, 
    tm.tree_id,
    tt.name as tree_name
    FROM
    category_tree_map tm, 
    categories c, 
    category_translations t,
    category_tree_translations tt 
    WHERE 
    c.tree_id      = tm.tree_id and 
    c.category_id  = t.category_id and 
    tm.object_id   = :package_id and
    tm.tree_id = tt.tree_id and
    c.deprecated_p = 'f'
    ORDER BY 
    tt.name,
    t.name
    </querytext>
  </fullquery>

  <fullquery name="pm::util::subsite_assignees_list_of_lists_not_cached.get_assignees">
    <querytext>
      SELECT DISTINCT
      p.first_names || ' ' || p.last_name as name,
      p.person_id
      FROM
      persons p,
      acs_rels r,
      membership_rels mr
      WHERE
      r.object_id_one = :user_group_id and
      mr.rel_id = r.rel_id and
      p.person_id = r.object_id_two and
      member_state = 'approved'
      ORDER BY name
    </querytext>
  </fullquery>
  
</queryset>
