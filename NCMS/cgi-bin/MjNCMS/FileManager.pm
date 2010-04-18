package MjNCMS::FileManager;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Fry: Let's see, a giant brain is basically a giant nerd. Where would a nerd go? 
#
# (c) Futurama
#
#
#     _________________________________
#    |.--------_--_------------_--__--.|
#    ||    /\ |_)|_)|   /\ | |(_ |_   ||
#    ;;`,_/``\|__|__|__/``\|_| _)|__ ,:|
#   ((_(-,-----------.-.----------.-.)`)
#    \__ )        ,'     `.        \ _/
#    :  :        |_________|       :  :
#    |-'|       ,'-.-.--.-.`.      |`-|
#    |_.|      (( (*  )(*  )))     |._|
#    |  |       `.-`-'--`-'.'      |  |
#    |-'|        | ,-.-.-. |       |._|
#    |  |        |(|-|-|-|)|       |  |
#    :,':        |_`-'-'-'_|       ;`.;
#     \  \     ,'           `.    /._/
#      \/ `._ /_______________\_,'  /
#       \  / :   ___________   : \,'
#        `.| |  |           |  |,'
#          `.|  |           |  |
#            |  | SSt       |  |
#
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use Mojo::JSON;

use File::Path qw/make_path remove_tree /;
use File::stat;
use Filesys::Tree qw/tree/;
use Switch 'Perl6';

sub new {
  
  my $self = {}; shift;
  
  bless $self;
  return $self

  
} #-- new

sub set_paths ($$) {
    my $self = shift;
    my $cfg = shift;

    return undef 
        unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return undef 
        unless 
            (
                ${$cfg}{'root_url'} &&
                length ${$cfg}{'root_url'} &&
                ${$cfg}{'root_path'} &&
                length ${$cfg}{'root_path'} 
            );
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} = 
            ${$cfg}{'root_url'};
    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} = 
            ${$cfg}{'root_path'};
    
    unless (-d $self->{'ROOT_PATH'}) {
        
        return undef if -e $self->{'ROOT_PATH'};
        
        eval { make_path($self->{'ROOT_PATH'}) };
        if ($@) {
            #&t_of("Couldn't create root dir: $@");
            return undef;
        }  
      
    }
    
    unless (-d $self->{'ROOT_PATH'} . '/Files') {
        eval { make_path($self->{'ROOT_PATH'} . '/Files') };
        if ($@) {
            #&t_of("Couldn't create  Images dir: $@");
            return undef;
        }  
    }
    
    unless (-d $self->{'ROOT_PATH'} . '/Flash') {
        eval { make_path($self->{'ROOT_PATH'} . '/Flash') };
        if ($@) {
            #&t_of("Couldn't create  Flash dir: $@");
            return undef;
        }  
    }
    
    unless (-d $self->{'ROOT_PATH'} . '/Images') {
        eval { make_path($self->{'ROOT_PATH'} . '/Images') };
        if ($@) {
            #&t_of("Couldn't create  Images dir: $@");
            return undef;
        }  
    }
    
    return 1;
} #-- set_paths

sub set_filemanager_id ($$) {
    my $self = shift;
    my $filemanager_id = shift;
    
    return undef unless $filemanager_id && length $filemanager_id;
    
    $self->{'FILEMANAGER_ID'} = $filemanager_id;
    
    return 1;
} #-- set_filemanager_id

sub run_action ($$) {

    my $self = shift;
    my $action = shift;
    
    given ($action) {
        when ('get_path_directory_tree') { return &_get_path_directory_tree($self); }
        when ('get_path_listing') { return &_get_path_listing($self); }
        when ('upload_file') { return &_upload_file($self); }
        when ('create_directory') { return &_create_directory($self); }
        when ('delete_path') { return &_delete_path($self); }
        when ('rename_path') { return &_rename_path($self); }
        default { return undef; }
    }
    
    return undef;

} #-- run_action

sub _tree_files_to_seq_array ($$$) {
    my ($path, $tree, $level) = @_;
    my @local_files = ();
    my $slavecount;
    
    $level = 1 unless $level;
    
    if ($tree && ref $tree && ref $tree eq 'HASH') {
        foreach my $file (sort keys %$tree) {
            push @local_files, {
                name => $file, 
                path => $path . '/' . $file, 
                level => $level, 
            };
            if(
                ${$$tree{$file}}{'contents'} &&
                ref ${$$tree{$file}}{'contents'} &&
                ref ${$$tree{$file}}{'contents'} eq 'HASH' &&
                ($slavecount = scalar keys %{${$$tree{$file}}{'contents'}}) 
            ){
                ${$local_files[scalar @local_files - 1]}{'slavecount'} = $slavecount;
                push @local_files, 
                    &_tree_files_to_seq_array(
                        $path . '/' . $file, 
                        ${$$tree{$file}}{'contents'}, 
                        ($level+1)
                    );
            }
        }
    }
    
    return @local_files;
} #-- _tree_files_to_seq_array

sub _get_path_directory_tree ($) {
    
    my $self = shift;
    my $path = $SESSION{'REQ'}->param('path');
    
    my ($dir_tree, $data);
    
    return undef unless {
        $path && 
        length $path && 
        $path =~ '^/' && 
        $path !~ /(\/|\\)\.*(\/|\\)/ 
    };

    $path =~ s/\/$//;
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} . $path;

    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} . $path;
    
    return undef unless -d $self->{'CURRENT_PATH'};
        
    $dir_tree = tree(
        {
            'directories-only' => 1, 
            'all' => 1, 
        } , $self->{'CURRENT_PATH'});
    
    $dir_tree = ${[values %$dir_tree]}[0]->{'contents'};
    
    $data = [&_tree_files_to_seq_array($path, $dir_tree, 1)];
    
    $data = [] unless scalar @$data;
    
    return {
        status => 'ok', 
        data => $data,
    }
    
} #-- _get_path_directory_tree

sub _get_path_listing ($) {

    my $self = shift;
    my $path = $SESSION{'REQ'}->param('path');
    
    my (
        $dir_content, $data, 
        $f_attrs, 
        @dirs, @files
    );
    
    return undef unless {
        $path && 
        length $path && 
        $path =~ '^/' && 
        $path !~ /(\/|\\)\.*(\/|\\)/ 
    };

    $path =~ s/\/$//;
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} . $path;

    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} . $path;
    
    return undef unless -d $self->{'CURRENT_PATH'};
        
    $dir_content = tree(
        {
            'max-depth' => 2,
            'all' => 1, 
        } , $self->{'CURRENT_PATH'});

    $dir_content = ${[values %$dir_content]}[0]->{'contents'};
    
    foreach my $file (sort keys %$dir_content){
        if ($$dir_content{$file}{'type'} eq 'd'){
            push @dirs, {
                name => $file, 
                type => 'd', 
                path => $path . '/' . $file, 
            };
        }
        else{
            $f_attrs = stat($self->{'CURRENT_PATH'} . '/' . $file);
            push @files, {
                name => $file, 
                type => 'f', 
                size => (sprintf "%.2f", ($f_attrs->size / (1048576))) . 'M',
                path => $path . '/' . $file, 
                urlpath => $self->{'CURRENT_URL'} . '/' . $file, 
            };
        }
    }
    
    $data = [@dirs, @files];
    
    return {
        status => 'ok', 
        data => $data, 
        path => $path . '/', 
    }   
    
} #-- _get_path_listing

sub _upload_file ($) {

    my $self = shift;
    my $path = $SESSION{'REQ'}->param('path');
    
    my (
        $data, $json
    );
    
    return undef unless {
        $path && 
        length $path && 
        $path =~ '^/' && 
        $path !~ /(\/|\\)\.*(\/|\\)/ &&
        $SESSION{'REQ'}->upload('clientpc_file') &&
        scalar $SESSION{'REQ'}->upload('clientpc_file')->filename &&
        scalar $SESSION{'REQ'}->upload('clientpc_file')->filename !~ /\/\\/
    };

    $path =~ s/\/$//;
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} . $path;

    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} . $path;
    
    return undef unless -d $self->{'CURRENT_PATH'};
    
    $json = Mojo::JSON->new;
    
    if (-e $self->{'CURRENT_PATH'} . '/' . $SESSION{'REQ'}->upload('clientpc_file')->filename){
    
        $data = $json->encode( {
            status => 'fail', 
            message => 'file exists', 
            path => $path . '/', 
            filemanager_id => $self->{'FILEMANAGER_ID'},
            
        } );
        
        $SESSION{'BS'}($data)->html_escape()->to_string();

        return qq~
            <html>
                <head>
                    <title>$data</title>
                </head>
                <body>
                    $data
                </body>
            </html>
        ~;
        
    }
    
    $SESSION{'REQ'}->upload('clientpc_file')->move_to($self->{'CURRENT_PATH'} . '/' . $SESSION{'REQ'}->upload('clientpc_file')->filename);

    $data = $json->encode( {
        status => 'ok', 
        path => $path . '/', 
        filemanager_id => $self->{'FILEMANAGER_ID'},
        
    } );
    
    $SESSION{'BS'}($data)->html_escape()->to_string();

    return qq~
        <html>
            <head>
                <title>$data</title>
            </head>
            <body>
                $data
            </body>
        </html>
    ~;
    
} #-- _upload_file

sub _create_directory ($){
    
    my $self = shift;
    my $path = $SESSION{'REQ'}->param('path');
    my $dir_name = $SESSION{'REQ'}->param('newdir_name');
    
    return undef unless {
        $path && 
        length $path && 
        $path =~ '^/' && 
        $path !~ /(\/|\\)\.*(\/|\\)/ && 
        $dir_name && 
        length $dir_name && 
        $dir_name !~ /\/|\\/
    };

    $path =~ s/\/$//;
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} . $path;

    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} . $path;
    
    return undef unless -d $self->{'CURRENT_PATH'};
    
    return {
        status => 'fail', 
        message => 'directory with this name exists alredy',
        path => $path . '/', 
    } if (-e $self->{'CURRENT_PATH'} . '/' . $dir_name);
    
    eval { make_path($self->{'CURRENT_PATH'} . '/' . $dir_name) };
    if ($@) {
        return {
            status => 'fail', 
            message => 'directory was not created for some reasons', 
            path => $path . '/', 
        }
    }
    
    return {
        status => 'ok', 
        path => $path . '/', 
    }   
    
} #-- _create_directory

sub _delete_path ($) {
    
    my $self = shift;
    my $path = $SESSION{'REQ'}->param('path');
    my $rm_file = $SESSION{'REQ'}->param('rm_file');
    
    return undef unless {
        $path && 
        length $path && 
        $path =~ '^/' && 
        $path !~ /(\/|\\)\.*(\/|\\)/ && 
        $rm_file && 
        length $rm_file && 
        $rm_file !~ /\/|\\/
    };

    $path =~ s/\/$//;
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} . $path;

    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} . $path;
    
    return undef unless -d $self->{'CURRENT_PATH'};
    
    return {
        status => 'fail', 
        message => 'File you want to delete is not exist',
        path => $path . '/', 
    } unless (-e $self->{'CURRENT_PATH'} . '/' . $rm_file);
    
    eval { remove_tree($self->{'CURRENT_PATH'} . '/' . $rm_file); };
    if ($@) {
        return {
            status => 'fail', 
            message => 'directory was not deleted for some reasons', 
            path => $path . '/', 
        }
    }
    
    return {
        status => 'ok', 
        path => $path . '/', 
    }
    
} #-- _delete_path

sub _rename_path ($) {
    
    my $self = shift;
    my $path = $SESSION{'REQ'}->param('path');
    my $old_name = $SESSION{'REQ'}->param('old_name');
    my $new_name = $SESSION{'REQ'}->param('new_name');
    
    return undef unless {
        $path && 
        length $path && 
        $path =~ '^/' && 
        $path !~ /(\/|\\)\.*(\/|\\)/ &&
        $old_name && 
        length $old_name &&
        $old_name !~ /\/|\\/ && 
        $new_name && 
        length $new_name && 
        $old_name !~ /\/|\\/
    };

    $path =~ s/\/$//;
    
    $self->{'CURRENT_URL'} = 
        $self->{'ROOT_URL'} . $path;

    $self->{'CURRENT_PATH'} = 
        $self->{'ROOT_PATH'} . $path;
    
    return undef unless -d $self->{'CURRENT_PATH'};
    
    return {
        status => 'fail', 
        message => 'File you want to rename is not exist',
        path => $path . '/', 
    } unless (-e $self->{'CURRENT_PATH'} . '/' . $old_name);
    
    return {
        status => 'fail', 
        message => 'File with new name is exist',
        path => $path . '/', 
    } if (-e $self->{'CURRENT_PATH'} . '/' . $new_name);
    
    eval { rename($self->{'CURRENT_PATH'} . '/' . $old_name, $self->{'CURRENT_PATH'} . '/'  . $new_name); };
    if ($@) {
        return {
            status => 'fail', 
            message => 'directory was not renamed for some reasons', 
            path => $path . '/', 
        }
    }
    
    return {
        status => 'ok', 
        path => $path . '/', 
    }
    
} #-- _rename_path

1;
