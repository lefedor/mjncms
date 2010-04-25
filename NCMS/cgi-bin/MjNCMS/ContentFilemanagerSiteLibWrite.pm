package MjNCMS::ContentFilemanagerSiteLibWrite;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Routes on content-side [Site], Read/Write part
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

use MjNCMS::FileManager;

########################################################################
#                    Functions to read/write filemanager data
########################################################################

sub fm_getresponce (;$$) {

    my $action = $_[0];
    $action = $SESSION{'REQ'}->param('action')
        unless $action;

    my $filemanager_id = $_[1];
    $filemanager_id = $SESSION{'REQ'}->param('filemanager_id')
        unless $filemanager_id;
    
    return undef unless $action;
    return undef unless $filemanager_id;
    
    return {
        status => 'fail', 
        message => 'userfiles path or directory not set. or both :)', 
    } unless (
        $SESSION{'USERFILES_URL'} &&
        $SESSION{'USERFILES_PATH'}
    );
    
    my $fm = MjNCMS::FileManager->new();
    
    return {
        status => 'fail', 
        message => 'userfiles paths set fail', 
    } unless $fm->set_paths({
            #login is better, but there are can be bad letters, or non-latin chars
            root_url => $SESSION{'USERFILES_URL'} . '/' . $SESSION{'USR'}->{'member_id'}, 
            root_path => $SESSION{'USERFILES_PATH'} . '/' . $SESSION{'USR'}->{'member_id'}, 
        });
    
    return {
        status => 'fail', 
        message => 'filemanager_id set fail', 
    } unless $fm->set_filemanager_id($filemanager_id);
    
    return $fm->run_action($action);
    
} #-- fm_getresponce

1;
