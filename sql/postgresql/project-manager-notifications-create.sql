-- Following directions at
-- http://openacs.org/doc/openacs-HEAD/tutorial-notifications.html

-- using pm_task_notif_type instead of lars_blogger_notif_type
-- using project-manager instead of lars-blogger

create function inline_0() returns integer as '
declare
    impl_id integer;
    v_foo integer;
begin
    -- the notification type impl
    impl_id := acs_sc_impl__new (
           ''NotificationType'',
           ''pm_task_notif_type'',
           ''project-manager''
    );

    v_foo := acs_sc_impl_alias__new (
          ''NotificationType'',
          ''pm_task_notif_type'',
          ''GetURL'',
          ''pm::task::get_url'',
          ''TCL''
    );

    v_foo := acs_sc_impl_alias__new (
          ''NotificationType'',
          ''pm_task_notif_type'',
          ''ProcessReply'',
          ''pm::task::process_reply'',
          ''TCL''
    );

    PERFORM acs_sc_binding__new (
          ''NotificationType'',
          ''pm_task_notif_type''
    );

    v_foo:= notification_type__new (
        NULL,
        impl_id,
        ''pm_task_notif'',
        ''Task Notification'',
        ''Notifications of task changes'',
        now(),
        NULL,
        NULL,
        NULL
    );

    -- enable the various intervals and delivery methods
    insert into notification_types_intervals
    (type_id, interval_id)
    select v_foo, interval_id
    from notification_intervals where name in (''instant'',''hourly'',''daily'');

    insert into notification_types_del_methods
    (type_id, delivery_method_id)
    select v_foo, delivery_method_id
    from notification_delivery_methods where short_name in (''email'');


    return (0);
end;
' language 'plpgsql';


select inline_0();
drop function inline_0();
