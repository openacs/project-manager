<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="roles_query">
    <querytext>
        SELECT
        role_id,
        one_line,
        description,
        is_observer_p,
        sort_order
        FROM 
        pm_roles
    </querytext>
</fullquery>

</queryset>
