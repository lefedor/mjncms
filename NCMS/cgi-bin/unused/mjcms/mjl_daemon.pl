#!/usr/bin/env perl
package MjCMS;

########################################################################
#  OLD VARIANT. Just first touch with ::Lite Possible comment this and try
# mj_daemon.pl current actual daemon
########################################################################

our $VERSION = '0.001-pre-alpha';

use common::sense;

use locale;
use POSIX qw/locale_h /;
use lib qw~./ ~;

#C-based memcached api
use Cache::Memcached::Fast;

#Fast captcha outsorcing service [ GD::SecurityImage may be later - load cpu more ]
use Captcha::reCAPTCHA;

#4 Session store @memcache/database
use Data::Serializer;

use Mojolicious::Lite; # 'app', 'post', 'get', 'any', 'shagadelic' is exported
use Mojo::URL;
use Mojo::Log;
use Mojo::Headers;

use MojoX::Renderer::TT;
#use MojoX::Renderer::Cache;

#use MojoX::Session;

use MjCMS::Config qw/:subs :vars /;
use MjCMS::Service qw/:subs :vars /;
use MjCMS::Session qw/:subs /;
use MjCMS::I18N;
use MjCMS::User;
use MjCMS::Menus;
use MjCMS::Content;
#use MjCMS::Shop;
#use MjCMS::Adverstment;


########################################################################
#	     				Template Toolkit AS tpl engine
########################################################################
my $tt_parsetask = {
		blocks => [], 
		body => undef, 
	};
my $tt_tpl_includepath = [];
my $tt_tpl_filterslist = {};

my %TT_VARS = ();
my %TT_CALLS = ();

#To allow set this vars from submodules - for put get/post route inits there
sub set_tt_var ($$) {
	my ($key, $val) = @_;
	$TT_VARS{$key} = $val;
}
sub set_tt_call ($$) {
	my ($key, $sub) = @_;
	$TT_CALLS{$key} = $sub;
}

my $tt = MojoX::Renderer::TT->build(
	mojo => app,
	template_options =>
	  { 
		ANYCASE => 0, #derictives case
		INCLUDE_PATH => $tt_tpl_includepath, #site-specific paths set ref
		ABSOLUTE => 0, #only relative paths
		RELATIVE => 1, #load files from root [includes, etc]
		AUTO_RESET => 1, #?check if req again later
		VARIABLES => {
			SESSION => \%SESSION, #global session env
			TT_VARS => \%TT_VARS, #tt vars zoo
			TT_CALLS => \%TT_CALLS, #tt subs zoo jail - clear, add only required subs, pass tpl
			tt_action => undef, 
			tt_module => undef,
			
		}, #alias for 'PRE_DEFINE => {}'
		WRAPPER => 'index.tpl', #this is main template decorator
		FILTERS => $tt_tpl_filterslist,  #site-specific filters set ref
		PLUGIN_BASE => 'MjCMS::Template::Filter', #TT plugins, 'loc' also.
		COMPILE_DIR => '../tmp/tt_ctpls/anti_relative', #consider deepest MjCMS::Config::$cfg_alternatives{'sitename'}::tt_tpls_root relative dir level-up :)
		
	  }, 
);
app->renderer->add_handler(tpl => $tt);
app->renderer->default_handler('tpl');
app->renderer->default_format('html');
app->renderer->encoding('utf-8');
app->renderer->types->type(tt => 'text/html');

#this enry for closing/saving session, etc - 'service' routines at end
app->plugins->add_hook(
	#before_dispatch => sub {
	after_dispatch => sub {
		my ($self, $c) = @_;
		if (scalar keys %{$SESSION{'COOKIES_RES'}}) {
			foreach my $cookie (values %{$SESSION{'COOKIES_RES'}}) {
				$cookie->value($SESSION{'BS'}($cookie->value())->url_escape) if $cookie->value();
				$cookie->comment($SESSION{'BS'}($cookie->comment())->url_escape) if $cookie->comment();
				$c->tx->res->cookies($cookie);
			}
			if ($SESSION{'PAGE_CACHABLE'}) {
				$c->tx->res->headers->header('Cache-Control' => 'private, max-age=315360000');
			}
			#$c->tx->res->cookies(@{$c->tx->res->cookies}, values %{$SESSION{'COOKIES_RES'}});
		}
		
		my $url;
		if($SESSION{'REDIR'}){
			$url = $SESSION{'SERVER_URL'} . $SESSION{'REDIR'} unless $SESSION{'REDIR'} =~ /^\w+\:\/\//;
			#$url =~ s/(\?|\&)rnd=\d+/$1.'rnd='.$SESSION{'RND'}/ge;
			if($url =~ /rnd=\d+/){
				#$url =~ s/(\?|\&)rnd=\d+/$1.'rnd='.$SESSION{'RND'}/ge;
			}
			$url = Mojo::URL->new($url);
			$c->redirect_to($url);
			return;
		}
		return unless my $started = $c->stash('started');
		#$c->app / $c->tx is avaliable from here
		#session_store();
	}, 
);


########################################################################
#							Every call reinit sub
########################################################################
ladder sub {
	my $self = shift;
	#this is each time reinit sub, return 1 - means continue, 0 - stop/interrupt
	my $url = Mojo::URL->new($self->tx->req->url->base);

	my $server_scheme = $url->scheme;
	my $server_name = $url->host;
	my $server_port = $url->port;
	
	if (!$server_name || $server_name !~ /\w+/) {
		$self->redirect_to('/_static/msg/no_server.shtml');
		return 0;
	}
	
	#multi-site thing :)
	my $cfg = &get_config($server_name . ((scalar $server_port)? ':'.$server_port:''));#from MjCMS::Config
	unless ($cfg && ref $cfg) {
		$self->redirect_to('/_static/msg/no_cfg.shtml');
		return 0;
	}
	
	$SESSION{'SERVER_SCHEME'} = $server_scheme;
	$SESSION{'SERVER_NAME'} = $server_name;
	$SESSION{'SERVER_PORT'} = $server_port;
	$SESSION{'SERVER_URL'} = $SESSION{'SERVER_SCHEME'} . '://' . $SESSION{'SERVER_NAME'};
	$SESSION{'SERVER_URL'} .= ':'.$SESSION{'SERVER_PORT'} if ( 
		(scalar $SESSION{'SERVER_PORT'}) && 
		(scalar $SESSION{'SERVER_PORT'} != 80) );
	
	$SESSION{'LOG'} = Mojo::Log->new(
		path  => $$cfg{'log_file'},
		level => $$cfg{'log_level'}? $$cfg{'log_level'}:'warn',
	) if $$cfg{'log_file'};
	
	eval {
		$SESSION{'SITE_LOCALE'} = $$cfg{'site_locale'};
		setlocale(LC_CTYPE, $SESSION{'SITE_LOCALE'});
		setlocale(LC_ALL, $SESSION{'SITE_LOCALE'});
	} if $$cfg{'site_locale'};
	
	$SESSION{'SITE_LOCALE'} = $$cfg{'site_contectemail'} if $$cfg{'site_contectemail'};
	
	$$cfg{'site_powered_by'} = 'MjCMS - Mojolicious::Lite CMS' unless $$cfg{'site_powered_by'};
	$self->tx->res->headers->header('X-Powered-By' => $$cfg{'site_powered_by'});
	$self->tx->res->headers->header('Content-Type' => 'text/html; charset='.$$cfg{'site_coding'}) if $$cfg{'site_coding'};
	if ($$cfg{'site_extra_headers'} && ref $$cfg{'site_extra_headers'} && ref $$cfg{'site_extra_headers'} eq 'HASH') {
		foreach my $header (keys %{$$cfg{'site_extra_headers'}}) {
			$self->tx->res->headers->header($header => ${$$cfg{'site_extra_headers'}}{$header});
		}
	}
	$self->app->renderer->encoding($$cfg{'site_coding'}) if $$cfg{'site_coding'};
	
	if ($$cfg{'tt_tpls_root'}) {
		$self->app->renderer->root($$cfg{'tt_tpls_root'});
	}
	else {
		$self->app->renderer->root('../public_html/tt_tpls/mjcms');
	}
	
	%{$tt_tpl_filterslist} = ();
	@{$tt_tpl_includepath} = ();
	push @{$tt_tpl_includepath}, @{$$cfg{'tt_tpls_paths'}};
	%TT_VARS = (
		html_lang => $$cfg{'site_html_lang'}? $$cfg{'site_html_lang'}:'en',
		xml_lang => $$cfg{'site_xml_lang'}? $$cfg{'site_xml_lang'}:'en',
		html_charset => $$cfg{'site_coding'}? $$cfg{'site_coding'}:'utf-8',
		CSS => [], 
		JS => [], 
		site_name => $$cfg{'site_name'}? $$cfg{'site_name'}:'MjCMS',
		
	);
	%TT_CALLS = (
		sort_jscss => \&sv_sort_jscss, 
		inarray => \&inarray, 
		
	);

	$self->app->static->root($$cfg{'site_htmlstatic_root'}) if $$cfg{'site_htmlstatic_root'};
	
	$SESSION{'REQ'} = $self->req;
	$SESSION{'REFERER'} = $SESSION{'REQ'}->param('referer');
	$SESSION{'COOKIES_RES'} = {};#hash with cookies @responce [values will be push @tx->res->cookies() @end]
	$SESSION{'COOKIES_REQ'} = {};#hash with cookies @request name=cookie
	foreach my $cookie (@{$self->tx->req->cookies}) {
		$cookie->value($SESSION{'BS'}($cookie->value())->url_unescape) if $cookie->value();
		${$SESSION{'COOKIES_REQ'}}{$cookie->name} = $cookie;
	}
	$SESSION{'HTTP_REFERER'} = ${$SESSION{'REQ'}->env}{'HTTP_REFERER'};
	$SESSION{'HTTP_USER_AGENT'} = ${$SESSION{'REQ'}->env}{'HTTP_USER_AGENT'};#used @ smf auth
	$SESSION{'REMOTE_ADDR'} = ${$SESSION{'REQ'}->env}{'REMOTE_ADDR'};#used @ recaptcha #no this envs @ 'daemon' test mode
	
	#Set this depends how you JS framework rly marks ajax requests [this is for mootools]
	$SESSION{'REQ_ISAJAX'} = undef;
	if($SESSION{'REQ'}->headers->header('X-Requested-With') && 
		$SESSION{'REQ'}->headers->header('X-Requested-With') eq 'XMLHttpRequest') {
			$SESSION{'REQ_ISAJAX'} = 1;
	}
		
	
	$SESSION{'CURRENT_PAGE'} = $SESSION{'SERVER_URL'}.'/'.
		((length($SESSION{'REQ'}->query_params))? '?'.($SESSION{'REQ'}->query_params):'');
	
	$SESSION{'REDIR'} = undef; # redirect;
	
	$SESSION{'DBH'} = &get_dbh(
		$$cfg{'dbh_host'}, 
		$$cfg{'dbh_port'}, 
		$$cfg{'dbh_base'}, 
		$$cfg{'dbh_user'}, 
		$$cfg{'dbh_pass'}
	);
	unless ($SESSION{'DBH'}) {
		$self->redirect_to('/_static/msg/no_dbh.shtml');
		return 0;
	}
		
	$SESSION{'MEMD'} = new Cache::Memcached::Fast({
		servers => $$cfg{'memd_servers'},
		namespace => '',
		connect_timeout => 0.2,
		io_timeout => 0.5,
		close_on_error => 1,
		compress_threshold => 100_000,
		compress_ratio => 0.5,
		compress_methods => [ 
			\&IO::Compress::Gzip::gzip,
			\&IO::Uncompress::Gunzip::gunzip 
		],
		max_failures => 3,
		failure_timeout => 2,
		ketama_points => 150,
		nowait => 1,
		hash_namespace => 1,
		serialize_methods => [ 
			\&Storable::freeze, 
			\&Storable::thaw 
		],
		utf8 => ($^V ge v5.8.1 ? 1 : 0),
		max_size => 256 * 1024,
	}) if ($$cfg{'memd_servers'} && ref $$cfg{'memd_servers'} && ref $$cfg{'memd_servers'} eq 'ARRAY');
	
	$SESSION{'MEMD'}->namespace($$cfg{'memd_vars_prefix'}? $$cfg{'memd_vars_prefix'}:'') if $SESSION{'MEMD'};
	
	$SESSION{'DBH'}->do('SET NAMES '.($SESSION{'DBH'}->quote($$cfg{'dbh_enc'})).';') if $$cfg{'dbh_enc'};
	$SESSION{'PREFIX'} = $$cfg{'dbh_prefix'} || '';
	$SESSION{'FORUM_PREFIX'} = $$cfg{'dbh_forum_prefix'} || '';
	
	$SESSION{'RND'} =  sprintf "%05u", rand 100000;
	$SESSION{'PAGE_CACHABLE'} = undef;
	$SESSION{'ALLOW_T_OF'} = $$cfg{'allow_t_of'} if $$cfg{'allow_t_of'};
	
	$SESSION{'ADM_URL'} = $$cfg{'adm_url'} || '/mjadmin';
	$SESSION{'FORUM_URL'} = $$cfg{'forum_url'} || undef;
	$SESSION{'THEME_URLPATH'} = $$cfg{'tt_tpls_theme_urlpath'} || '/_static/';

	$SESSION{'CAPTCHA'} = undef;
	if($$cfg{'recaptcha_publickey'} && $$cfg{'recaptcha_privatekey'}){
		#api is quite simpe: ->get_mjcaptcha()/->check_mjcaptcha()
		#so could be later impemented wth GD::SecurityImage easily if req
		$SESSION{'CAPTCHA'} = Captcha::reCAPTCHA->new;
		$SESSION{'RECAPTCHA_PUBLKEY'} = $$cfg{'recaptcha_publickey'};
		$SESSION{'RECAPTCHA_PRIVKEY'} = $$cfg{'recaptcha_privatekey'};
		$SESSION{'CAPTCHA'}->{'get_mjcaptcha'} = sub {return $SESSION{'CAPTCHA'} -> get_html($SESSION{'RECAPTCHA_PUBLKEY'});};
		$SESSION{'CAPTCHA'}->{'check_mjcaptcha'} = sub (;$$) {
			my ($challenge, $response) = @_;
			$challenge = $SESSION{'REQ'}->param('recaptcha_challenge_field') unless $challenge;
			$response = $SESSION{'REQ'}->param('recaptcha_response_field') unless $response;
			
			return undef if (!$challenge || !$response);
			my $result = $SESSION{'CAPTCHA'}->check_answer(
				$SESSION{'RECAPTCHA_PRIVKEY'}, $SESSION{'REMOTE_ADDR'},
				$challenge, $response
			);
			if ($result->{'is_valid'}) {
				return 1;
			}
			#my $error = $result->{error};
			return undef;
		};
	}
	
	$SESSION{'CRYPT_KEY'} = $$cfg{'crypt_key'} || '';
	$SESSION{'MD_CHK_KEY'} = $$cfg{'md_chk_key'} || '';
	$SESSION{'COOKIE_SIGN_KEY'} = $$cfg{'cookie_sign_key'} || 'n0tjustpassw0rd';
	$self->app->secret($SESSION{'COOKIE_SIGN_KEY'});
	
	$SESSION{'SITE_LANGS'} = ($$cfg{'site_langs'} && ref $$cfg{'site_langs'} && ref $$cfg{'site_langs'} eq 'HASH')? $$cfg{'site_langs'}:{'en' => 'MjCMS/Locales/mjcms_en.po'};
	
	unless (scalar keys %{$SESSION{'SITE_LANGS'}}) {
		$self->redirect_to('/_static/msg/no_lang.shtml');
		return 0;
	}
	
	$SESSION{'SITE_LANG_DEFT'} = $$cfg{'site_lang_deft'}? $$cfg{'site_lang_deft'}:${[keys %{$SESSION{'SITE_LANGS'}}]}[0];
	$SESSION{'MEMC_UNTRANS_STRS'} = $$cfg{'memc_untrans_strs'}? $$cfg{'memc_untrans_strs'}:undef;
		
	$SESSION{'LOC'} = MjCMS::I18N->new();
	unless ($SESSION{'LOC'} -> init_langs($SESSION{'SITE_LANGS'})) {
		$self->redirect_to('/_static/msg/no_lang.shtml');
		return 0;
	}
	
	$SESSION{'AUTH_ENGINE'} = $$cfg{'auth_engine'} || 'smf';
	$SESSION{'AUTH_COOKIE'} = $$cfg{'auth_cookie'} || 'SMFCookie762';
	$SESSION{'REM_COOKIE'} = $$cfg{'rem_cookie'} || 'MjtAuthRem';
	$SESSION{'SESS_COOKIE'} = $$cfg{'sess_cookie'} || 'MjtSession';
	$SESSION{'SESS_COOKIE_PHP'} = $$cfg{'sess_cookie_php'} || 'PHPSESSID';
	$SESSION{'COOKIE_FOREVER_TIME'} = $$cfg{'cookie_forever_time'} || '2147483647';#smw @ year 2015 :)
	$SESSION{'GUESTUSER_ISACTIVE'} = defined($$cfg{'guestuser_isactive'})? $$cfg{'guestuser_isactive'}:1;
	$SESSION{'DEFAULT_REG_ROLE'} = $$cfg{'default_reg_role'} || '0';
	
	$SESSION{'ALLOW_SW_TOSLAVEUSERS'} = $$cfg{'allow_sw_toslaveusers'} || 0;
	$SESSION{'ALLOW_SW_AWPROLES'} = $$cfg{'allow_sw_awproles'} || 0;

	$SESSION{'SESSION_PHP'} = 
		${$SESSION{'COOKIES_REQ'}}{$SESSION{'SESS_COOKIE_PHP'}} 
		if ${$SESSION{'COOKIES_REQ'}}{$SESSION{'SESS_COOKIE_PHP'}};
	
	$SESSION{'USR'} = MjCMS::User->new($self, $SESSION{'AUTH_ENGINE'});
	unless ($SESSION{'USR'}){
		$self->redirect_to('/_static/msg/no_usr.shtml');
		return 0;
	}
	unless($SESSION{'USR'} -> auth()){
		$self->redirect_to('/_static/msg/no_auth.shtml'.'?state='. ($SESSION{'USR'} -> {'last_state'}));
		return 0;
	}
	
	if($SESSION{'USR'}->{'member_sitelng'} && 
		$SESSION{'USR'}->{'member_sitelng'} ne $SESSION{'SITE_LANG_DEFT'} && 
		&inarray([keys %{$SESSION{'SITE_LANGS'}}], $SESSION{'USR'}->{'member_sitelng'})){
			$SESSION{'LOC'}->set_lang($SESSION{'USR'}->{'member_sitelng'});
	}
	else{
		$SESSION{'USR'}->{'member_sitelng'} = $SESSION{'SITE_LANG_DEFT'};
	}
	
	#&t_of($self);
	
	return 1;
};

########################################################################
########################################################################
##							CONTENT ACTIONS
########################################################################
########################################################################

########################################################################
#							ADMIN PANEL
########################################################################
#admin panel main page
get '/mjadmin' => sub {#no GET params here (?some=thing&), this is not for this match rule. /only/path
	my $self = shift;
	#$self is Mojolicious::Controller object. 
	#[ http://search.cpan.org/~kraih/Mojo-0.999914/lib/Mojolicious/Controller.pm ]
	#here and alter @get/post/any
	#$self->req : req object
	#[ http://search.cpan.org/~kraih/Mojo-0.999914/lib/Mojo/Message/Request.pm ]
	#$self->req->params;
	#$self->req->query_params;
	#scalar $self->req->cookies;
	#etc...
	#or just $TT_VARS{'some'} = $self->param('some'); for single param
	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'index';
	$self->render('admin/admin_index');
};

get '/mjadmin/menus' => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'menus';
	$TT_CALLS{'menus_get_list'} = \&MjCMS::Menus::menus_get_list;
	$self->render('admin/admin_index');

};

get '/mjadmin/menus/add' => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'menus_add';
	if($self -> param('parent_menu_id') && $self -> param('parent_menu_id') =~ /^\d+$/){
		$TT_VARS{'parent_menu_id'} = $self -> param('parent_menu_id');
	}
	$self->render('admin/admin_index');

};

get '/mjadmin/menus/add/(:parent_menu_id)' => [parent_menu_id => qr/\d+/] => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'menus_add';
	$TT_CALLS{'menus_get_record'} = \&MjCMS::Menus::menus_get_record;
	$TT_VARS{'parent_menu_id'} = $self -> param('parent_menu_id');
	$self->render('admin/admin_index');

};

post '/mjadmin/menus/add' => sub {
	my $self = shift;
	
	my $res = MjCMS::Menus::menus_mk_node({
		parent => $SESSION{'REQ'}->param('parent_menu_id')? $SESSION{'REQ'}->param('parent_menu_id'):0, 
		name => $SESSION{'REQ'}->param('menu_text'), 
		cname => $SESSION{'REQ'}->param('menu_cname'), 
		is_active => $SESSION{'REQ'}->param('menu_isactive'), 
		link => $SESSION{'REQ'}->param('menu_link'), 
		lang => $SESSION{'REQ'}->param('menu_lang'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			menu_id => $res->{'menu_id'}, 
			parent_menu_id => $SESSION{'REQ'}->param('parent_menu_id'), 
			menu_level => $res->{'menu_level'}, 
			seq_order => $res->{'seq_order'}, 
			
		});
	}

};


get '/mjadmin/menus/delete/(:rm_menu_id)' => [rm_menu_id => qr/\d+/] => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'menus_delete';
	$TT_VARS{'rm_menu_id'} = $self -> param('rm_menu_id');
	$TT_CALLS{'menus_get_record'} = \&MjCMS::Menus::menus_get_record;
	$self->render('admin/admin_index');

};

post '/mjadmin/menus/delete' => sub {
	my $self = shift;
	
	my $res = &MjCMS::Menus::menus_rm_node($SESSION{'REQ'}->param('rm_menu_id'));
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			menu_id => $SESSION{'REQ'}->param('rm_menu_id'), 
		});
	}

};

get '/mjadmin/menus/edit/(:menu_id)' => [menu_id => qr/\d+/] => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'menus_edit';
	$TT_VARS{'menu_id'} = $self -> param('menu_id');
	$TT_CALLS{'menus_get_record'} = \&MjCMS::Menus::menus_get_record;
	$TT_CALLS{'menus_get_record_tree'} = \&MjCMS::Menus::menus_get_record_tree;
	$TT_CALLS{'menus_get_parent_tree'} = \&MjCMS::Menus::menus_get_parent_tree;
	$self->render('admin/admin_index');

};

post '/mjadmin/menus/edit' => sub {
	my $self = shift;
	
	my $res = &MjCMS::Menus::menus_edit_node({
		menu_id => $SESSION{'REQ'}->param('menu_id'), 
		name => $SESSION{'REQ'}->param('menu_text'), 
		cname => $SESSION{'REQ'}->param('menu_cname'), 
		link => $SESSION{'REQ'}->param('menu_link'), 
		is_active => $SESSION{'REQ'}->param('menu_isactive'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			menu_id => $SESSION{'REQ'}->param('menu_id'), 
			
		});
	}

};

post '/mjadmin/menus/setsequence' => sub {
	my $self = shift;
	
	my %menus_weight = &get_suffixed_params('m_ord_');
	my $res = &MjCMS::Menus::menus_set_sequence(\%menus_weight);

	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			parent_menu_id => $SESSION{'REQ'}->param('parent_menu_id'), 
			
		});
	}

};

get '/mjadmin/menus/managetrans/(:menu_id)' => [menu_id => qr/\d+/] => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'menus_managetrans';
	$TT_CALLS{'menus_get_transes'} = \&MjCMS::Menus::menus_get_transes;
	$TT_CALLS{'menus_get_record'} = \&MjCMS::Menus::menus_get_record;
	$TT_VARS{'menu_id'} = $self -> param('menu_id');
	$self->render('admin/admin_index');

};

post '/mjadmin/menus/addtrans' => sub {
	my $self = shift;
	
	my $res = MjCMS::Menus::menus_mk_trans_record({
		menu_id => $SESSION{'REQ'}->param('menu_id'), 
		name => $SESSION{'REQ'}->param('menu_trans'), 
		link => $SESSION{'REQ'}->param('menu_altlink'), 
		lang => $SESSION{'REQ'}->param('menu_lang'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			menu_id => $res->{'menu_id'}, 
			
		});
	}
};

post '/mjadmin/menus/updtrans' => sub {
	my $self = shift;
	
	my $res = MjCMS::Menus::menus_edit_trans_record({
		menu_id => $SESSION{'REQ'}->param('menu_id'), 
		name => $SESSION{'REQ'}->param('menu_trans'), 
		link => $SESSION{'REQ'}->param('menu_altlink'), 
		lang => $SESSION{'REQ'}->param('menu_lang'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			menu_id => $res->{'menu_id'}, 
			
		});
	}
};

get '/mjadmin/menus/deltrans/(:menu_id)/(:lang_id)' => [menu_id => qr/\d+/] => sub {
	my $self = shift;
	
	my $res = MjCMS::Menus::menus_rm_trans_record({
		menu_id => $self->param('menu_id'), 
		lang => $self->param('menu_lang'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/menus' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			menu_id => $res->{'menu_id'}, 
			
		});
	}
};








get '/mjadmin/content/cats' => sub {
	my $self = shift;

	$SESSION{'PAGE_CACHABLE'} = 1;
	$TT_VARS{'tt_module'} = 'admin';
	$TT_VARS{'tt_action'} = 'content_cats';
	$TT_CALLS{'content_get_catlist'} = \&MjCMS::Content::content_get_catlist;
	$self->render('admin/admin_index');

};





########################################################################
#							WEBSHOP ACTIONS
########################################################################
#browse categories
get '/shop/(index|page).html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#filter categories
get '/shop/(search|srch_page).html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

get '/shop/rss' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#view products
get '/shop/product.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#browse cart
get '/shop/cart.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#edit cart
post '/shop/cart.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#complete order
post '/shop/order.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};


########################################################################
#							USER ACTIONS
########################################################################
#register new
get '/usr/new' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#register new
post '/usr/new' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#validate
get '/usr/validate' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#login
get '/usr/login' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#login do
post '/usr/login' => sub {
	my $self = shift;
	
	my $url;
	if($SESSION{'USR'}->login()){
		if($SESSION{'REFERER'}){
			$url = $SESSION{'REFERER'};
		}
		elsif($SESSION{'HTTP_REFERER'}){
			$url = $SESSION{'HTTP_REFERER'};
		}
		else{
			$url = $SESSION{'USR'}->{'profile'}->{'startpage'};
		}
		$url = '/' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else{
		$self->render(text => 'Auth failed: ' . $SESSION{'USR'}->{'last_state'});
	}
	
};
#user account
get '/usr/view' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#edit user account
get '/usr/edit' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#do update user account
post '/usr/edit' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#forgot password form
get '/usr/forgot' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#reminder action
post '/usr/forgot' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};
#logout
get '/usr/logout' => sub {
	my $self = shift;
	
	my $url;
	if($SESSION{'USR'}->logout()){
		if($SESSION{'REFERER'}){
			$url = $SESSION{'REFERER'};
		}
		elsif($SESSION{'HTTP_REFERER'}){
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = '/' unless $url;
		$SESSION{'REDIR'} = $url;
		return;
	}
	else{
		$self->render(text => 'Logout failed: ' . $SESSION{'USR'}->{'last_state'});
	}
};


########################################################################
#							CMS/BLOG ACTIONS
########################################################################
#mainpage - should be done supercached )
get '/' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#view category content
get '//index.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#category by date history
get '/bydate_dd_mm_yyyy.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#category by tag history
get '/bytag_.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

#view article content
get '/*.html' => sub {
	my $self = shift;
	$self->render(text => 'Hello from MjCMS!');
};

########################################################################
#						ACTUALLY FORCE IT FLY!
########################################################################
if (scalar @ARGV){
	#if command line params is set
	shagadelic();
}
else {
	#example of out-of-box start ready settings
	shagadelic('fcgi_prefork', 
	#shagadelic('fastcgi', 
	#shagadelic('fcgi', 
	#shagadelic('daemon', 
		#'--daemonize'
		'--listen', 'mojotest:3042', 
		'--start', '4', 
		'--minspare', '4',
		'--maxspare', '10'
	);
}

=pod


#This is example of ngnix site settings file
server {
    listen mojotest:82;
    server_name mojotest www.mojotest;
		#Main location
            location / {
 
                 fastcgi_pass   mojotest:3042;

                 #pure fcgi, fuck all
                 #fastcgi_param  MOJO_APP             MyMojo::App;
                 #fastcgi_param  SCRIPT_NAME          http://127.0.0.1:3042; #!
                 #fastcgi_param  PATH_INFO            $fastcgi_script_name;  #!
                 
                 #server data:
                 fastcgi_param  SERVER_NAME          $server_name;
                 fastcgi_param  SERVER_ADDR          $server_addr;
                 fastcgi_param  SERVER_PORT          $server_port;
                 #query data:
                 fastcgi_param  REQUEST_METHOD       $request_method;
                 fastcgi_param  QUERY_STRING         $query_string;
                 fastcgi_param  CONTENT_TYPE         $content_type;
                 fastcgi_param  CONTENT_LENGTH       $content_length;
                 fastcgi_param  REQUEST_URI          $request_uri;
                 fastcgi_param  HTTP_REFERER		 $http_referer;
                 #for antispam, etc:
                 fastcgi_param  REMOTE_USER          $remote_user; 
                 fastcgi_param  REMOTE_ADDR          $remote_addr; 
                 fastcgi_param  REMOTE_PORT          $remote_port;
                 fastcgi_param  HTTP_CLIENT_IP       $http_client_ip;
                 fastcgi_param HTTP_X_FORWARDED_FOR  $http_x_forwarded_for; 

 
				 client_max_body_size       10m;
				 client_body_buffer_size    256k;

				 proxy_connect_timeout      90;
				 proxy_send_timeout         90;
				 proxy_read_timeout         90;

				 proxy_buffer_size          4k;
				 proxy_buffers              4 32k;
				 proxy_busy_buffers_size    64k;
				 proxy_temp_file_write_size 64k;
				 

				 #Enable gzip
				 gzip						on;
				 gzip_http_version			1.1; #compression-supported
				 gzip_vary					on;
				 #Min file/responce to compress, in bytes
				 gzip_min_length				4096; #dunno waste time for small files
				 #Gzip for proxy users?
				 gzip_proxied				any;
				 # MIME-types to compress
				 gzip_types       			text/plain text/xml application/xml application/xml+rss application/x-javascript text/javascript text/css text/json;# text/html;
				 #no gzip for IE-6-x
				 #gzip_disable     			"msie6";
				 gzip_disable 				“MSIE [1-6].(?!.*SV1)”;
				 #gzip-compression level
				 gzip_comp_level  			6; #5 is also OK [ http://speedupyourwebsite.ru/books/speed-up-your-website/ ] 
				 #zip buffer - max transfer queue (16 * 8kb == ), 4 * default
				 #http://blog.leetsoft.com/2007/7/25/nginx-gzip-ssl
				 gzip_buffers 16 8k;

				 
             }

			 #Static files location
			 #shtml - 'static' html pages )
			 location ~* ^.+\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|wav|bmp|rtf|js|shtml)$ {
			     root /var/www/static/mjcms/public_html/;
			     expires   10y;
				 header set Cache-Control public;
			 }
}

    Keep it simple, no magic unless absolutely necessary.

    Code should be written with a Perl6 port in mind.

    No refactoring unless a very important feature absolutely depends on it.

    It's not a feature without a test.

    A feature is only needed when the majority of the userbase benefits from it.

    Features may not be changed without being deprecated for at least one major release.

    Deprecating a feature should be avoided at all costs.

    A major release can be version number independent and is signaled by a new unique code name.

    Only add prereqs if absolutely necessary.

    Domain specific languages should be avoided in favor of Perl'ish solutions.

    No inline POD.

    Documentation belongs to the book, module POD is just an API reference.

    Lines should not be longer than 78 characters and we indent with 4 whitespaces.

    Code should be run through Perl::Tidy with the included .perltidyrc.

    No spaghetti code.

    Code should be organized in blocks and those blocks should be commented.

    Comments should be funny if possible.

    Every file should contain at least one quote from The Simpsons or Futurama.

    No names outside of the CREDITS section of Mojo.pm.

    No Elitism.

    Peace!

=cut

