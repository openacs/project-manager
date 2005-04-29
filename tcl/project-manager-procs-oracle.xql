<?xml version="1.0"?>
<!--  -->
<!-- @author Jade Rubick (jader@bread.com) -->
<!-- @creation-date 2004-06-11 -->
<!-- @arch-tag: 9a0aca80-2974-4b08-a211-25482d8419b5 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>oracle</type>
    <version>8.0</version>
  </rdbms>
  
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

  
</queryset>
