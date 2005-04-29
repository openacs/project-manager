# 

ad_library {
    
    Init file to schedul registered procedures for notifications
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-14
    @arch-tag: e72c34cc-2ed9-42c5-8423-d9b349f0e6c4
    @cvs-id $Id$
}

# set up daily emailings
pm::task::email_status_init
