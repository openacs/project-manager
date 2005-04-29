<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="default_project_roles_query">
    <querytext>
        SELECT
        role_id,
        party_id
        FROM 
        pm_default_roles
    </querytext>
</fullquery>

</queryset>
