package MjNCMS::Renderer::TT;
#package MojoX::Renderer::TT; #reasons lines 56-80

use warnings;
use strict;
use base 'Mojo::Base';

use Template ();
use Carp     ();
use File::Spec ();

use MjNCMS::Config qw/:subs :vars /;

our $VERSION = '0.31';

__PACKAGE__->attr('tt');

sub build {
    my $self = shift->SUPER::new(@_);
    $self->_init(@_);
    return sub { $self->_render(@_) }
}

sub _init {
    my $self = shift;
    my %args = @_;

    my $mojo = delete $args{mojo};

    my $dir = $mojo && $mojo->home->rel_dir('tmp/ctpl');

    # TODO
    #   take and process options :-)

    my %config = (
        ( $mojo ? (INCLUDE_PATH => $mojo->home->rel_dir('templates') ) : () ),
        COMPILE_EXT => '.ttc',
        COMPILE_DIR => ($dir || File::Spec->tmpdir),
        UNICODE     => 1,
        ENCODING    => 'utf-8',
        CACHE_SIZE  => 128,
        RELATIVE    => 1,
        ABSOLUTE    => 1,
        %{$args{template_options} || {}},
    );

    $self->tt(Template->new(\%config))
      or Carp::croak "Could not initialize Template object: $Template::ERROR";

    return $self;
}

sub _render {
    my ($self, $renderer, $c, $output, $options) = @_;

    #FedorFL, Dirty hack, but what else to do?
    ${$self->tt->context->load_templates->[0]}{'INCLUDE_PATH'}=
				($TT_CFG{'includepath'} &&
				ref $TT_CFG{'includepath'} && 
				(ref $TT_CFG{'includepath'} eq 'ARRAY')
			)? $TT_CFG{'includepath'}:(
					(
						!$TT_CFG{'includepath'} || 
						ref $TT_CFG{'includepath'}
					)? []:[$TT_CFG{'includepath'}]
				) if $TT_CFG{'includepath'};
    ${$self->tt->context->load_plugins->[0]}{'PLUGINS'}=$TT_CFG{'plugins'}
		if (
			$TT_CFG{'plugins'} && 
			ref $TT_CFG{'plugins'} && 
			ref $TT_CFG{'plugins'} eq 'HASH' &&
			scalar (keys %{$TT_CFG{'plugins'}})
		);
    ${$self->tt->context->config}{'FILTERS'}=$TT_CFG{'filterlist'}
		if (
			$TT_CFG{'filterlist'} && 
			ref $TT_CFG{'filterlist'} && 
			ref $TT_CFG{'filterlist'} eq 'HASH' &&
			scalar (keys %{$TT_CFG{'filterlist'}})
		);

    my $template_path;
    unless($template_path = $c->stash->{'template_path'}) {
        $template_path = $renderer->template_path($options);
    }

    unless (
        $self->tt->process(
            $template_path, {%{$c->stash}, c => $c},
            $output, {binmode => ":utf8"}
        )
      )
    {
        Carp::carp $self->tt->error . "\n";
        return 0;
    }
    else {
        return 1;
    }
}


1;
