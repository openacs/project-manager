# /packages/project-manager/www/comments/add.tcl

ad_page_contract {
    
    Adds a general comment to a project or task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-09
    @arch-tag: 7448d185-3d5c-43f2-853e-de7c929c4526
    @cvs-id $Id$
} {
    object_id:integer,notnull
    title:notnull
    return_url:notnull
    {type "task"}
    {attach_p "f"}
    {description:html ""}
} -properties {
} -validate {
} -errors {
}

set display_title "[_ project-manager.lt_Add_a_comment_to_titl]"
set context [list "$display_title"]


ad_form -name comment \
    -form {
        acs_object_id_seq:key

        {object_id:text(hidden)
            {value $object_id}
        }

        {return_url:text(hidden)
            {value "$return_url"}
        }

        {type:text(hidden)
            {value "$type"}
        }

        {title:text
            {label "[_ project-manager.Title]"}
            {html {size 50}}
        }
        
        {description:richtext(richtext),optional
            {label "[_ project-manager.Comment_1]"}
            {html { rows 9 cols 40 wrap soft}}}
        
        {send_email_p:text(select),optional
            {label "[_ project-manager.Send_email]"}
            {options {{"[_ acs-kernel.common_Yes]" "t"} {"[_ acs-kernel.common_no]" "f"}}}
        }
        
        {attach_p:text(select),optional
            {label "[_ project-manager.Attach_a_file]"}
            {options {{"[_ acs-kernel.common_Yes]" "t"} {"[_ acs-kernel.common_no]" "f"}}}
            {value "f"}
        }
        
    } -new_request {
        
        set description [template::util::richtext::create "" {}]
    
    } -on_submit {
        
        # insert the comment into the database
        set description_body [template::util::richtext::get_property contents $description]
        set description_format [template::util::richtext::get_property format $description]

        set comment_id [pm::util::general_comment_add \
                            -object_id $object_id \
                            -title "$title" \
                            -comment "$description_body" \
                            -mime_type "$description_format" \
                            -send_email_p $send_email_p \
                            -type $type]

        # does not seem to be working for some reason
        util_user_message -message "[_ project-manager.lt_Comment_ad_quotehtml_]"

        if { [string equal $attach_p "f"] && ![empty_string_p $return_url] } {
            ad_returnredirect $return_url
        } else {
            ad_returnredirect "/comments/view-comment?[export_vars { comment_id return_url }]"
        }
    }

