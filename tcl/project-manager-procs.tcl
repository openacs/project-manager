ad_library {

    Project Manager Projects Library
    
    Utility procedures for project manager

    @creation-date 2003-08-25
    @author Jade Rubick <jader@bread.com>
    @cvs-id $Id$

}

namespace eval pm::util {}


ad_proc -public pm::util::hours_day {
} {
    Returns the number of hours in the workday
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-24
    
    @return 
    
    @error 
} {
    return [util_memoize [list pm::util::hours_day_not_cached]]
}


ad_proc -public pm::util::hours_day_not_cached {
} {
    Returns the number of hours in the workday
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-24
    
    @return 
    
    @error 
} {
    return 8
}


ad_proc -public pm::util::days_work {
    {-hours_work:required}
    {-pretty_p "f"}
} {
    Returns the number of days work
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-24
    
    @param hours_work

    @return 
    
    @error 
} {
    set hours_day [pm::util::hours_day]

    if {![string equal $hours_day 0]} {
        set number [expr double($hours_work) / $hours_day]
    }

    set return_val [pm::util::trim_number -number $number]

    if {[string is true $pretty_p]} {
        if {$return_val < 1} {
            return "less than 1"
        }
    }
    
    return $return_val
}


ad_proc -public pm::util::trim_number {
    {-number:required}
    {-precision "4"}
} {
    Trims zeros off the end of a number
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-24
    
    @param precision

    @return 
    
    @error 
} {
    set return_val [format "%0.${precision}f" $number]
    set return_val [string trimright $return_val 0]
    set return_val [string trimright $return_val .]

    return $return_val
}



ad_proc -public pm::util::datenvl {
    -value 
    -value_if_null 
    -value_if_not_null
} {
    Extended nvl, for dates only
} {
    if {[string equal $value "{} {} {} {} {} {}"] \
            || [empty_string_p $value]} {
        return $value_if_null
    } else {
        return $value_if_not_null
    }
}


ad_proc -public pm::util::reformat_date {
    the_date
} {
    the end date comes in this format 2004 05 17
    we need to get it in the {2004} {05} {17} {} {} {} format
    
    @author Jade Rubick (jader@bread.com)
    
    @creation-date 2004-09-23
    
    
    @param the_date


    @return 
    
    @error 
} {

    regexp {(.*) (.*) (.*)} $the_date match year month day
        if {[exists_and_not_null year]} {
            set return_val "$year $month $day {} {} {}"
        } else {
            set return_val "{} {} {} {} {} {}"
        }
    
    return $return_val
}


ad_proc -public pm::util::string_truncate_and_pad {
    -length
    {-ellipsis "..."}
    -string
} {
    Truncates a string to a given length, or pads it to match a given length
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-14
    
    @param length

    @param ellipsis

    @param string

    @return 
    
    @error 
} {

    set new_string [string_truncate -len $length -ellipsis $ellipsis -- $string]
    set new_string_length [string length $new_string]

    if {$new_string_length < $length} {
        set new_string "$new_string[string repeat " " [expr $length - $new_string_length]]"
    }

    return $new_string
}


ad_proc -private pm::util::word_diff {
	{-old:required}
	{-new:required}
	{-split_by {}}
	{-filter_proc {ad_quotehtml}}
	{-start_old {<strike><i><font color="blue">}}
	{-end_old {</font></i></strike>}}
	{-start_new {<u><b><font color="red">}}
	{-end_new {</font></b></u>}}
} {
    This procedure has been BACKPORTED from OpenACS HEAD. That means
    you should not use it in your own applications. If you do, you'll
    need to update your application once OpenACS 5.2 is available, and
    create a dependency on OpenACS 5.2 in your .info file. 

	Does a word (or character) diff on two lines of text and indicates text
	that has been deleted/changed or added by enclosing it in
	start/end_old/new.
	
	@param	old	The original text.
	@param	new	The modified text.
	
	@param	split_by	If split_by is a space, the diff will be made
	on a word-by-word basis. If it is the empty string, it will be made on
	a char-by-char basis.

	@param	filter_proc	A filter to run the old/new text through before
	doing the diff and inserting the HTML fragments below. Keep in mind
	that if the input text is HTML, and the start_old, etc... fragments are
	inserted at arbitrary locations depending on where the diffs are, you
	might end up with invalid HTML unless the original HTML is quoted.

	@param	start_old	HTML fragment to place before text that has been removed.
	@param	end_old		HTML fragment to place after text that has been removed.
	@param	start_new	HTML fragment to place before new text.
	@param	end_new		HTML fragment to place after new text.

	@see ad_quotehtml
	@author Gabriel Burca
} {

	if {$filter_proc != ""} {
		set old [$filter_proc $old]
		set new [$filter_proc $new]
	}

	set old_f [ns_tmpnam]
	set new_f [ns_tmpnam]
	set old_fd [open $old_f "w"]
	set new_fd [open $new_f "w"]
	puts $old_fd [join [split $old $split_by] "\n"]
	puts $new_fd [join [split $new $split_by] "\n"]
	close $old_fd
	close $new_fd

	# Diff output is 1 based, our lists are 0 based, so insert a dummy
	# element to start the list with.
	set old_w [linsert [split $old $split_by] 0 {}]
	set sv 1

#	For debugging purposes:
#	set diff_pipe [open "| diff -f $old_f $new_f" "r"]
#	while {![eof $diff_pipe]} {
#		append res "[gets $diff_pipe]<br>"
#	}

	set diff_pipe [open "| diff -f $old_f $new_f" "r"]
	while {![eof $diff_pipe]} {
		gets $diff_pipe diff
		if {[regexp {^d(\d+)(\s+(\d+))?$} $diff full m1 m2]} {
			if {$m2 != ""} {set d_end $m2} else {set d_end $m1}
			for {set i $sv} {$i < $m1} {incr i} {
				append res "${split_by}[lindex $old_w $i]"
			}
			for {set i $m1} {$i <= $d_end} {incr i} {
				append res "${split_by}${start_old}[lindex $old_w $i]${end_old}"
			}
			set sv [expr $d_end + 1]
		} elseif {[regexp {^c(\d+)(\s+(\d+))?$} $diff full m1 m2]} {
			if {$m2 != ""} {set d_end $m2} else {set d_end $m1}
			for {set i $sv} {$i < $m1} {incr i} {
				append res "${split_by}[lindex $old_w $i]"
			}
			for {set i $m1} {$i <= $d_end} {incr i} {
				append res "${split_by}${start_old}[lindex $old_w $i]${end_old}"
			}
			while {![eof $diff_pipe]} {
				gets $diff_pipe diff
				if {$diff == "."} {
					break
				} else {
					append res "${split_by}${start_new}${diff}${end_new}"
				}
			}
			set sv [expr $d_end + 1]
		} elseif {[regexp {^a(\d+)$} $diff full m1]} {
			set d_end $m1
			for {set i $sv} {$i < $m1} {incr i} {
				append res "${split_by}[lindex $old_w $i]"
			}
			while {![eof $diff_pipe]} {
				gets $diff_pipe diff
				if {$diff == "."} {
					break
				} else {
					append res "${split_by}${start_new}${diff}${end_new}"
				}
			}
			set sv [expr $d_end + 1]
		}
	}
	
	for {set i $sv} {$i < [llength $old_w]} {incr i} {
		append res "${split_by}[lindex $old_w $i]"
	}

	file delete -- $old_f $new_f

	return $res
}


ad_proc -public pm::util::logger_url {} {
    Returns the URL for the primary logger URL
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-24
    
    @return 
    
    @error 
} {
    set return_val [parameter::get -parameter "LoggerPrimaryURL" -default ""]

    if {[empty_string_p $return_val]} {
        ns_log Error "Project-manager: need to set up LoggerPrimaryURL in parameters"
        util_user_message -message "Administrator needs to set up logger integration"
    }

    return $return_val
}


ad_proc -public pm::util::general_comment_add {
    {-object_id:required}
    {-title:required}
    {-comment ""}
    {-mime_type:required}
    {-user_id ""}
    {-peeraddr ""}
    {-type "task"}
    {-send_email_p "f"}
} {
    Adds a general comment to a task or project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-10
    
    @param object_id The item_id for the task or project

    @param title The title for the comment

    @param comment The body of the comment

    @param mime_type The mime_type for the comment

    @param user_id Optional, the user_id making the comment. If left
    empty, set to the ad_conn user_id

    @param peeraddr The IP address of the user making the comment.
    If empty, set to the ad_conn peeraddr

    @param type Either task or project. 

    @param send_email_p Whether or not to send out an email
    notification t or f

    @return the comment_id of the new comment
    
    @error -1 if there is an error 
} {
    if {[empty_string_p $user_id]} {
        set user_id [ad_conn user_id]
    }

    if {[empty_string_p $peeraddr]} {
        set peeraddr [ad_conn peeraddr]
    }

    if {![string equal $type task] && ![string equal $type project]} {
        return -1
    }

    # insert the comment into the database
    set is_live [ad_parameter AutoApproveCommentsP {general-comments} {t}]

    set comment_id [db_nextval acs_object_id_seq]

    db_transaction {
        db_exec_plsql insert_comment {}
        
        db_dml add_entry {}
        
        db_1row get_revision {}
       
        db_dml set_content {} -blobs [list $comment]
        
        if {![empty_string_p $user_id]} {
            permission::grant \
                -object_id $comment_id \
                -party_id $user_id \
                -privilege "read"

            permission::grant \
                -object_id $comment_id \
                -party_id $user_id \
                -privilege "write"
        }

    }

    # now send out email
    
    if {[string equal $send_email_p t]} {
        
        # task

        if {[string equal $type task]} {

            set assignees [pm::task::assignee_email_list -task_item_id $object_id]

            if {[llength $assignees] > 0} {

                set to_address $assignees

                set from_address [db_string get_from_email {}]
                
                set task_url [pm::task::get_url $object_id]
                
                set subject "Task comment: $title"
                
                # convert to HTML
                set richtext_list [list $comment $mime_type]
                set comment_html [template::util::richtext::get_property html_value $richtext_list]

                set content "<a href=\"$task_url\">$title</a> <p />$comment_html"
                
                pm::util::email \
                    -to_addr  $to_address \
                    -from_addr $from_address \
                    -subject $subject \
                    -body $content \
                    -mime_type "text/html"
            }

        }

        # project

        if {[string equal $type project]} {

            set assignees [pm::project::assignee_email_list -project_item_id $object_id]

            if {[llength $assignees] > 0} {

                set to_address $assignees

                set from_address [db_string get_from_email {}]
                
                set project_url [pm::project::url \
                                     -project_item_id $object_id]
                
                set subject "Project comment: $title"

                # convert to HTML
                set richtext_list [list $comment $mime_type]
                set comment_html [template::util::richtext::get_property html_value $richtext_list]

                set content "<a href=\"$project_url\">$title</a> <p />$comment_html"

                
                pm::util::email \
                    -to_addr  $to_address \
                    -from_addr $from_address \
                    -subject $subject \
                    -body $content \
                    -mime_type "text/html"
            }


        }
    }


    return $comment_id
}


ad_proc -public pm::util::email {
    {-to_addr:required}
    {-from_addr:required}
    {-subject:required}
    {-body ""}
    {-mime_type "text/plain"}
} {
    Wrapper to send out email, also converts body to text/plain format
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-10
    
    @param to_addr list of email addresses to send to

    @param from_addr

    @param subject

    @param body

    @param mime_type

    @return 
    
    @error 
} {

    # HTML portions of this copied from notification::email::send

    if {[string equal $mime_type "text/plain"]} {
        set body_text $body
        set body_html [ad_html_text_convert -from $mime_type -to "text/html" -- $body]
    } elseif {[string equal $mime_type "text/html"]} {
        set body_text [ad_html_text_convert -from $mime_type -to "text/plain" -- $body]
        set body_html $body

    } else {
        set body_text [ad_html_text_convert -from $mime_type -to "text/plain" -- $body]
        set body_html [ad_html_text_convert -from $mime_type -to "text/html" -- $body]

    }

    # Use this to build up extra mail headers
    set extra_headers [ns_set new]

    # This should disable most auto-replies
    ns_set put $extra_headers Precedence list

    set message_data [build_mime_message $body_text $body_html]
    ns_set put $extra_headers MIME-Version [ns_set get $message_data MIME-Version]
    ns_set put $extra_headers Content-ID [ns_set get $message_data Content-ID]
    ns_set put $extra_headers Content-Type [ns_set get $message_data Content-Type]
    set content [ns_set get $message_data body]

    foreach to $to_addr {

        acs_mail_lite::send \
            -to_addr  "$to" \
            -from_addr "$from_addr" \
            -subject "$subject" \
            -body $content \
            -extraheaders $extra_headers
    }
}


ad_proc -public pm::util::category_selects {
    {-export_vars ""}
    {-category_id ""}
    {-package_id ""}
} {
    Returns an HTML fragment of forms, one for each
    category tree, suitable for use on a page.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param export_vars Variables already exported with export_vars -form
    
    @param category_id If set, the currently selected category

    @return 
    
    @error 
} {
    if {[empty_string_p $package_id]} {
        set package_id [ad_conn package_id]
    }
    
    # caches results for 2.5 minutes.
    return [util_memoize [list pm::util::category_selects_not_cached -export_vars $export_vars -category_id $category_id -package_id $package_id] 300]
}



ad_proc -private pm::util::category_selects_not_cached {
    {-export_vars ""}
    {-category_id ""}
    -package_id:required
} {
    Returns an HTML fragment of category choices, suitable 
    for use on a page. This proc
    is used so that pm::util::category_selects can cache
    the categories
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param export_vars Variables already exported with export_vars -form
    
    @param category_id If set, the currently selected category

    @return 
    
    @error 
} {
    # Categories are arranged into category trees. 
    # Set up an array for each tree. The array contains the category for each tree
    
    set category_select ""
    set number_of_categories 0
    set last_tree ""
    set category_select ""

    db_foreach get_categories { } {

        if {![string equal $tree_name $last_tree] } {
            append category_select "<option value=\"\">** $tree_name **</option>"
        }

        if {[string equal $cat_id $category_id]} {
            set select "selected"
        } else {
            set select ""
        }

        append category_select "<option $select value=\"$cat_id\">$cat_name</option>"

        set last_tree $tree_name
        incr number_of_categories
    }

    if {$number_of_categories < 1} {
        return ""
    }

    set return_val "<form method=\"post\" action=\"index\">$export_vars <br /><select name=\"category_id\"><option value=\"\">--All Categories--</option>$category_select"

    append return_val "</select><input type=\"submit\" value=\"Go\" /></form>"
    
    return $return_val
}


ad_proc -public pm::util::package_id {
} {
    Returns the package ID for the project manager.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-16
    
    @return 
    
    @error 
} {
    return [db_string get_package_id {}]
}


ad_proc -public pm::util::url {
    {-fully_qualified_p "t"}
} {
    Returns the URL of where the project manager is located,
    fully qualified
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-16
    
    @return 
    
    @error 
} {
    set package_id [pm::util::package_id]

    if {[string is true $fully_qualified_p]} {
        set return_val [ad_url]
    } else {
        set return_val ""
    }
    append return_val [site_node::get_url_from_object_id -object_id $package_id]

    return $return_val
}


ad_proc -public pm::util::subsite_assignees_list_of_lists {
} {
    Returns a list of lists of possible assignees
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-13
    
    @return 
    
    @error 
} {
    set subsite_id [ad_conn subsite_id]
    return [util_memoize [list pm::util::subsite_assignees_list_of_lists_not_cached -subsite_id $subsite_id] 6000]
}


ad_proc -public pm::util::subsite_assignees_list_of_lists_not_cached {
    {-subsite_id ""}
} {
    Returns a list of lists of possible assignees
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-13
    
    @return 
    
    @error 
} {

    if [empty_string_p $subsite_id] {
	set subsite_id [ad_conn subsite_id]
    }
    
    set user_group_id [application_group::group_id_from_package_id \
                           -package_id $subsite_id]

    set assignees [db_list_of_lists get_assignees { }]
    
    return $assignees
}
