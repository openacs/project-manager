<?xml version="1.0"?>

<queryset>

  <fullquery name="pm::util::category_selects_not_cached.get_categories">
    <querytext>
    SELECT  t.name as cat_name,
            t.category_id as cat_id,
            tm.tree_id,
            tt.name as tree_name
    FROM category_tree_map tm,
         categories c,
         category_translations t,
         category_tree_translations tt
    WHERE c.tree_id      = tm.tree_id and
          c.category_id  = t.category_id and
          tm.object_id   = :package_id and
          tm.tree_id = tt.tree_id and
          c.deprecated_p = 'f'
    ORDER BY  tt.name,
              t.name
    </querytext>
  </fullquery>

  <fullquery name="pm::util::package_id.get_package_id">
    <querytext>
        SELECT package_id
        FROM   cr_folders
        WHERE  description = 'Project Repository'
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

  <fullquery name="pm::util::general_comment_add.add_entry">
    <querytext>
      insert into general_comments
      (comment_id,             
       object_id,              
       category)               
      values                   
      (:comment_id,            
       :object_id,             
       null)                   
    </querytext>
  </fullquery>

  <fullquery name="pm::util::general_comment_add.get_from_email">
    <querytext>
      select email from parties where party_id = :user_id
    </querytext>
  </fullquery>

</queryset>
