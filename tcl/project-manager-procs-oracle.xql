<?xml version="1.0"?>

<queryset>

<rdbms><type>oracle</type><version>9.2</version></rdbms>

  <fullquery name="pm::util::general_comment_add.get_revision">
    <querytext>
      select content_item.get_latest_revision(:comment_id) as revision_id from dual
    </querytext>
  </fullquery>

  <fullquery name="pm::util::general_comment_add.set_content">
    <querytext>
      update cr_revisions
      set content = empty_blob()
      where revision_id = :revision_id
      returning content into :1
    </querytext>
  </fullquery>

  <fullquery name="pm::util::general_comment_add.insert_comment">
    <querytext>
        begin
            :1 :=  acs_message.new (
                   message_id    => :comment_id,
                   reply_to      => NULL,
                   sent_date     => current_timestamp,
                   sender        => NULL,
                   rfc822_id     => NULL,
                   title         => :title,
                   description   => NULL,
                   mime_type     => :mime_type,
                   text          => NULL,
                   data          => empty_blob(),
                   parent_id     => 0,
                   context_id    => :object_id,
                   creation_user => :user_id,
                   creation_ip   => :peeraddr,
                   object_type   => 'acs_message',
                   is_live       => :is_live
                   );
        end;
    </querytext>
  </fullquery>

</queryset>
