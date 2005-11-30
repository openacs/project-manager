<?xml version="1.0"?>
<queryset>

<fullquery name="process_query">
    <querytext>
        SELECT p.process_id,
               p.one_line,
               p.description,
               p.party_id,
               to_char(p.creation_date,'YYYY-MM-DD') as creation_date_ansi,
               (select count(*) from pm_process_instance i where i.process_id =
        p.process_id) as instances
        FROM   pm_process_active p
        ORDER BY p.one_line        
    </querytext>
</fullquery>

</queryset>
