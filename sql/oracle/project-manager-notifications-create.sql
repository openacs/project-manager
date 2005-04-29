-- Following directions at
-- http://openacs.org/doc/openacs-HEAD/tutorial-notifications.html

-- using pm_task_notif_type instead of lars_blogger_notif_type
-- using project-manager instead of lars-blogger

declare
    impl_id integer;
    v_foo integer;
begin

    -- the notification type impl
    impl_id := acs_sc_impl.new (
           impl_contract_name  => 'NotificationType',
           impl_name           => 'pm_task_notif_type',
           impl_owner_name          => 'project-manager'
    );

    v_foo := acs_sc_impl_alias.new (
          impl_contract_name   => 'NotificationType',
          impl_name            => 'pm_task_notif_type',
          impl_operation_name  => 'GetURL',
          impl_alias           => 'pm::task::get_url',
          impl_pl              => 'TCL'
    );

    v_foo := acs_sc_impl_alias.new (
          impl_contract_name   => 'NotificationType',
          impl_name            => 'pm_task_notif_type',
          impl_operation_name  => 'ProcessReply',
          impl_alias           => 'pm::task::process_reply',
          impl_pl              => 'TCL'
    );

    acs_sc_binding.new (
          contract_name => 'NotificationType',
          impl_name     => 'pm_task_notif_type'
    );

    v_foo:= notification_type.new (
        type_id        => NULL,
        sc_impl_id     => impl_id,
        short_name     => 'pm_task_notif',
        pretty_name    => 'Task Notification',
        description    => 'Notifications of task changes',
        creation_date  => sysdate ,
        creation_user  => null,
        creation_ip    => null,
        context_id     => NULL
    );

    -- enable the various intervals and delivery methods
    insert into notification_types_intervals
    (type_id, interval_id)
    select v_foo, interval_id
    from notification_intervals where name in ('instant','hourly','daily');

    insert into notification_types_del_methods
    (type_id, delivery_method_id)
    select v_foo, delivery_method_id
    from notification_delivery_methods where short_name in ('email');

end;
/

show errors
