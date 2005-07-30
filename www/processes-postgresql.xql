<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="process_query">
    <querytext>
        SELECT
        p.process_id,
        p.one_line,
        p.description,
        p.party_id,
        to_char(p.creation_date,'YYYY-MM-DD HH24:MI:SS') as creation_date_ansi,
        (select count(*) from pm_process_instance i where i.process_id =
        p.process_id) as instances
        FROM 
        pm_process_active p
        ORDER BY
        p.one_line        
    </querytext>
</fullquery>

</queryset>
