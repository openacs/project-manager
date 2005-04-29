<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="wg_query">
    <querytext>
        SELECT
        workgroup_id,
        one_line,
        description,
        sort_order
        FROM 
        pm_workgroup
    </querytext>
</fullquery>

</queryset>
