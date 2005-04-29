<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="project_folders">
    <querytext>
        SELECT
        p.item_id,
        p.project_id,
        p.parent_id as folder_id,
        p.object_type as content_type,
        p.title as project_name,
        p.project_code,
        to_char(p.planned_start_date, 'Mon DD ''YY') as planned_start_date,
        to_char(p.planned_end_date, 'Mon DD ''YY') as planned_end_date,
        p.ongoing_p,
        p.actual_hours_completed,
        p.estimated_hours_total,
        to_char(p.estimated_finish_date, 'Mon DD ''YY') as estimated_finish_date,
        to_char(p.earliest_finish_date, 'Mon DD ''YY') as earliest_finish_date,
        to_char(p.latest_finish_date, 'Mon DD ''YY') as latest_finish_date
        FROM pm_projectsx p, cr_items i
        WHERE p.project_id = i.live_revision and
        p.parent_id = :root_folder
        ORDER BY p.title
    </querytext>
</fullquery>

</queryset>
