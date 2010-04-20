package MjNCMS::Mail;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# All messages are delivered by PlanetExpress delivery service :)
#

#
# SANTA But what about your other co-workers? 
#   Did either of you ever stop to think about Dr. Zoidberg's feelings? 
# FRY No! I swear! 
#
#   (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use MIME::Lite;
use MIME::Base64 qw/encode_base64 /;
use Encode qw(encode);

use locale;
use POSIX qw/locale_h /;
my $locale = 'ru_RU.UTF-8';
        setlocale(LC_CTYPE, $locale);
        setlocale(LC_ALL, $locale);


sub new () {
    my $self = {}; shift;
    
    my $cfg = shift;
    $cfg = {} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    #allow new()->new(), allow send logs youself, etc
    #return undef unless $$cfg{'to'};
    $$cfg{'to'} = $SESSION{'SITE_CONTACTEMAIL'} 
        unless $$cfg{'to'};    
    
    $$cfg{'from'} = $SESSION{'SITE_CONTACTEMAIL'} 
        unless $$cfg{'from'};    
    
    $$cfg{'subject'} = $SESSION{'SITE_NAME'} 
        unless $$cfg{'subject'};

    $$cfg{'from'} = join ', ', @{$$cfg{'from'}} 
        if ref $$cfg{'from'} && ref $$cfg{'from'} eq 'ARRAY';
    $$cfg{'to'} = join ', ', @{$$cfg{'to'}} 
        if ref $$cfg{'to'} && ref $$cfg{'to'} eq 'ARRAY';
    $$cfg{'cc'} = join ', ', @{$$cfg{'cc'}} 
        if ref $$cfg{'cc'} && ref $$cfg{'cc'} eq 'ARRAY';
    
    unless ($$cfg{'skip_enc'}){
        $$cfg{'from_enc'} = 
            &_field_to_base($$cfg{'from'})
                unless $$cfg{'from_enc'};
        $$cfg{'to_enc'} = 
            &_field_to_base($$cfg{'to'})
                unless $$cfg{'to_enc'};
        $$cfg{'cc_enc'} = 
            &_field_to_base($$cfg{'cc'})
                unless $$cfg{'cc_enc'};
        $$cfg{'subject_enc'} = 
            &_field_to_base($$cfg{'subject'})
                unless $$cfg{'subject_enc'};
    }
    $self->{'MESSAGE'} = MIME::Lite->new(
        From    => $$cfg{'from_enc'},
        To      => $$cfg{'to_enc'},
        Cc      => $$cfg{'cc_enc'},
        Subject => $$cfg{'subject_enc'},
        Type    => 'multipart/mixed'
    );
    
    $self->{'MIMETYPES'} = MIME::Types->new();
    
    bless $self;
    
    if ($$cfg{'text'}){
        $self->attach_text($$cfg{'text'});
    }
    if ($$cfg{'html'}){
        $self->attach_html($$cfg{'html'});
    }   
    return $self
} #-- new

sub rest ($$) {
    my $self = shift;
    
    my $cfg = shift;
    $cfg = {} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    $self->{'MESSAGE'} = MIME::Lite->new(
        From    => $self->{'MESSAGE'}->get('From'),
        To      => $self->{'MESSAGE'}->get('To'),
        Cc      => $self->{'MESSAGE'}->get('Cc'),
        Subject => $self->{'MESSAGE'}->get('Subject'),
        Type    => 'multipart/mixed'
    );
    
    return $self;
} #-- rest

sub update ($$) {
    my $self = shift;
    
    my $cfg = shift;
    return unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    foreach my $key (keys %$cfg){
        $$cfg{$key} = join ', ', @{$$cfg{$key}} 
            if ref $$cfg{$key} && ref $$cfg{$key} eq 'ARRAY';
        $self->{'MESSAGE'}->delete($key);
        $self->{'MESSAGE'}->add($key, $$cfg{$key});
    }
    
    return $self;
} #-- update

sub _str_to_base ($) {
    my $string = shift;

    return undef unless defined $string;

    if (uc($SESSION{'SITE_CODING'}) eq 'UTF-8') {
        $string = $SESSION{'BS'}($string)->encode($SESSION{'SITE_CODING'});
        $string = MIME::Base64::encode_base64($string,'');
    }
    else {
        $string = MIME::Base64::encode($string,'');
    }
    
    $string = '=?' . (uc($SESSION{'SITE_CODING'})) . '?B?' . $string . '?=';

    return $string;
} #-- _str_to_base

sub _field_to_base ($) {
    my $field = shift;
    
    return undef unless defined $field;
    
    if ($field =~ /<[A-Za-z0-9_\-\.]+\@/){
        #from, to, cc - "Name <email>" entryes - encode name, left email untoched
        $field =~ s/([^\s].+?)(\s*?<\s*?[A-Za-z0-9_\-\.]+\@)(.+?>)(\s*?\,\s*?)?/&_str_to_base($1) . $2 . $3 . $4/eg;
    }
    else {
        $field = &_str_to_base($field);
    }
    return $field
}
sub attach_text ($$) {
    my ($self, $text) = @_;
    
    return unless $text;
    
    $self->{'MESSAGE'}->attach(
        #Type     => 'TEXT',
        Type        => 'text/plain; charset=' . $SESSION{'SITE_CODING'},
        Data        => $text,
        Disposition => 'inline',
        
    );
    return $self;
} #-- attach_text

sub attach_html ($$) {
    my ($self, $html) = @_;
    
    return unless $html;
    
    $self->{'MESSAGE'}->attach(
        Type     => 'text/html; charset=' . $SESSION{'SITE_CODING'},
        Data     => $html,
        Disposition => 'inline',
        
    );
    return $self;
} #-- attach_html

sub attach_file ($$) {
    my ($self, $file_cfg) = @_;
    
    return unless $file_cfg;
    
    unless (defined $$file_cfg{'data'}) {
        unless (
            ref $file_cfg && 
            ref $file_cfg eq 'HASH' && 
            $$file_cfg{'path'} 
        ) {
            $file_cfg = {path => $$file_cfg{'path'}};
        }
        
        return unless -e $$file_cfg{'path'};
     
        unless ($$file_cfg{'filename'}) {
            $$file_cfg{'filename'} = pop @{[split '/', $$file_cfg{'path'}]}; 
        }
    }
    
    return if $$file_cfg{'filename'} =~ /\/|\\|:/;
    
    unless ($$file_cfg{'type'}) {
        $$file_cfg{'type'} = 
            ''.$self->{'MIMETYPES'}->mimeTypeOf($$file_cfg{'filename'});
        $$file_cfg{'type'} = 'application/octet-stream'
            unless $$file_cfg{'type'};
    }

    unless ($$file_cfg{'id'}) {
        $$file_cfg{'id'} = $$file_cfg{'filename'}; 
    }
    
    $$file_cfg{'deposition'} = 'attachment'
        if $$file_cfg{'is_attach'};
        
    $$file_cfg{'deposition'} = 'inline'
        if $$file_cfg{'is_inline'};
    
    unless (
        $$file_cfg{'deposition'} && 
        (
            $$file_cfg{'deposition'} eq 'inline' ||
            $$file_cfg{'deposition'} eq 'attachment' 
        )
    ) {
        $$file_cfg{'deposition'} = 'attachment'
    }
    
    unless (defined $$file_cfg{'readnow'}){
        $$file_cfg{'readnow'} = 0;
    }
    $$file_cfg{'readnow'} = $$file_cfg{'readnow'}? 1:0;
    
    $self->{'MESSAGE'}->attach(
        Type        =>    $$file_cfg{'type'},
        Data        =>    $$file_cfg{'data'},
        Path        =>    $$file_cfg{'path'},
        Id          =>    $$file_cfg{'id'},
        Filename    =>    $$file_cfg{'filename'},
        Disposition =>    $$file_cfg{'deposition'},
        ReadNow     =>    $$file_cfg{'readnow'},
    );
    return $self;
} #-- attach_file

sub send ($;$) {
    my $self = shift;
    
    $self->{'MESSAGE'}->send(@_);
    
    return $self;
} #-- send

sub as_string ($) {
    my $self = shift;
    
    return $self->{'MESSAGE'}->as_string();
} #-- as_string

sub to_string ($) {
    my $self = shift;
    
    return $self->as_string();
} #-- to_string

=pod

my $m = $SESSION{'MAILER'}->new({
    to => 'Федя <ffl.public@gmail.com>, ФедьКа <root@f8mobile.f8>', 
    subject => 'Здрасти|Hello',
    text => 'Тельце|Body',
    html => '<a href="/some">Тельце</a>',
})->send();

or 

$m = $SESSION{'MAILER'}->new({
    to => 'Федя <ffl.public@gmail.com>, ФедьКа <root@f8mobile.f8>', 
    subject => 'Здрасти',
});
$m->attach_text();#inline 
$m->attach_html();#inline 
$m->attach_file({
    path => '..'
    ||
    data => '...' && 
    name => 'asasa.gif',
    
    deposition => 'inline or attachment', attachmet default
    
    
});
$m->send();

to/from/cc/subject are base64 encoded unless new({skip_enc})

#&t_of($m->to_string);

=cut

1;
