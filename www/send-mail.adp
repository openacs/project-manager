<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<!-- 

       Parameters:

       party_ids   = List of party_id's to send a message. Here they are project assignees
       export_vars = variables that you want to be present on the include form (For example project_id)
       return_url  = Url to redirect after the process is finished
       file_ids    = revision_id of files you want to include in your message

 -->
<include src="/packages/acs-mail-lite/lib/email" party_ids=@party_ids@ export_vars=@export_vars@ return_url=@return_url;noquote@ object_id=@project_item_id@ no_callback_p="f" checked_p="f" use_sender_p="f" cc="@cc;noquote@" bcc="@bcc;noquote@" mime_type="@mime_type@" subject="@subject;noquote@">

