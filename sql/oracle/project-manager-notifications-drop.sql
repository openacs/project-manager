--
-- Project Manager
--
-- @author jader@bread.com
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert's UBB forums. Thanks Orchard Labs.
-- Jade in turn lifted this from gwong and ben.
--

begin
    for row in (select nt.type_id
               from notification_types nt
               where nt.short_name in ('pm_task_notif'))
    loop
        notification_type.del(row.type_id);
    end loop;
end;
/
show errors 


--
-- Service contract drop stuff was missing - Roberto Mello 
--

declare
        v_foo   integer;
        v_impl_id integer;
begin
        -- the notification type impl
        v_impl_id := acs_sc_impl.get_id (
                      'NotificationType',             -- impl_contract_name
                      'pm_task_notif_type'            -- impl_name
        );

        select type_id into v_foo
          from notification_types
         where sc_impl_id = v_impl_id
          and short_name = 'pm_task_notif';

        delete from notification_types_intervals
         where type_id = v_foo 
           and interval_id in ( 
                select interval_id
                  from notification_intervals 
                 where name in ('instant','hourly','daily')
        );

        delete from notification_types_del_methods
         where type_id = v_foo
           and delivery_method_id in (
                select delivery_method_id
                  from notification_delivery_methods 
                 where short_name in ('email')
        );

        notification_type.del (v_foo);

        acs_sc_binding.del (
          contract_name => 'NotificationType',
          impl_name =>  'pm_task_notif_type'
        );

        v_foo := acs_sc_impl.delete_alias (
                    'NotificationType',               -- impl_contract_name  
                    'pm_task_notif_type',             -- impl_name
                    'GetURL'                          -- impl_operation_name
        );

        v_foo := acs_sc_impl.delete_alias (
                    'NotificationType',               -- impl_contract_name 
                    'pm_task_notif_type',             -- impl_name
                    'ProcessReply'                    -- impl_operation_name
        );

        acs_sc_impl.del(
          'NotificationType',
          'pm_task_notif_type'
        );
    
end;
/
show errors
