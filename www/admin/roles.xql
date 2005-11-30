<queryset>

<fullquery name="roles_query">
    <querytext>
        SELECT role_id,
               one_line,
               description,
               is_observer_p,
               sort_order
        FROM   pm_roles
    </querytext>
</fullquery>

</queryset>
