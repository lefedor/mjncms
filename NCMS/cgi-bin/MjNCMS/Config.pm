package MjNCMS::Config;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#
# Zapp Branigan: You win again, gravity!! [crashing into planet]
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use vars qw/%MULTISESSION /;
keys(%MULTISESSION) = 32; #count of sites served

BEGIN {

    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/%SESSION %MULTISESSION %TT_CFG %TT_VARS %TT_CALLS /],
      subs => [qw/get_config /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');

	#Session hash
	my %SESSION; keys(%SESSION) = 128;
	
	#Template toolkit service variables
	my %TT_CFG; keys(%TT_CFG) = 8;
	my %TT_VARS; keys(%TT_VARS) = 16;
	my %TT_CALLS; keys(%TT_CALLS) = 16;
	
	$TT_CFG{'includepath'} = ();
	$TT_CFG{'filterlist'} = ();
	
}
	
#
#common settings for all sites, 
#final %cfg = (%common, %site-specific);#replace req keys
#site-specific lower vvv, @ sub get_config
#
my %CFG_COMMON = (
	#mysql settings
	
	#db splitted for possibility of replication-arch multi-db/cluster structure
	#if u leave databases_read/databases_reserve empty 
	#databases_write settings will be used insted them
	#
	#exact db setting are select randomly rule currently :)
	#but tryes to match position 4example 
	#if connects 2nd write, it will try connect 2nd read first, etc
	#see/edit MjNCMS::Plugin::MjncmsInit after the comment 'dbh lottery'
	
	databases_write => {
		#common => [#common is default dbh connection grp
		#	{
		#		dbh_host => 'hostname', 
		#		dbh_port => '3306', 
		#		dbh_user => 'user', 
		#		dbh_pass => 'password', 
		#		dbh_base => 'database_name', 
		#	}#,
		#],
		
		#users_db => [ #all data about smth @data's personal sql server
		#	{
		#		dbh_host => 'localhost', 
		#		dbh_port => '3306', 
		#		dbh_user => 'mojotest', 
		#		dbh_pass => 'mojotest', 
		#		dbh_base => 'mojotest', 
		#	},
		#],
		
	},

	#databases_read => {
		#common => [
		#	{
		#		dbh_host => 'localhost', #host 1, ...etc
		#		dbh_port => '3306', 
		#		dbh_user => 'mojotest', 
		#		dbh_pass => 'mojotest', 
		#		dbh_base => 'mojotest', 
		#	}, 
		#],
		
		#users_db => [ #all data about smth @data's personal sql server
		#	{
		#		dbh_host => 'localhost', 
		#		dbh_port => '3306', 
		#		dbh_user => 'mojotest', 
		#		dbh_pass => 'mojotest', 
		#		dbh_base => 'mojotest', 
		#	},
		#],
	
	#},

	#databases_reserve => {
		#common => [
		#	{
		#		dbh_host => 'localhost', 
		#		dbh_port => '3306', 
		#		dbh_user => 'mojotest', 
		#		dbh_pass => 'mojotest', 
		#		dbh_base => 'mojotest', 
		#	},
		#],
		
		#users_db => [ #all data about smth @data's personal sql server
		#	{
		#		dbh_host => 'localhost', 
		#		dbh_port => '3306', 
		#		dbh_user => 'mojotest', 
		#		dbh_pass => 'mojotest', 
		#		dbh_base => 'mojotest', 
		#	},
		#],
		
	#},

	#mysql connection options
	dbh_enc  => 'utf8', #will run 'SET NAMES XXX;' on it if set
	dbh_prefix => 'mj_', 
	dbh_forum_prefix => 'mjsmf_', 
	#if there param('dbh')==master - use 'write' dbh as 'read' anyway
	#for cluster lag situations
	dbh_master_afterpost_allow => 1, #1/0==undef: 
	
	#memcached settings
	memd_vars_prefix => 'mj:',  #deft prefix
	memd_servers => {
		common => {
			servers => [ 
				{ address => 'localhost:11211', weight => 2.5 },

			],
			vars_prefix => 'mj:', #or default
		}, 
		#more memd server groups
	},
	
	auth_engine => 'smf', 
	auth_cookie => 'MjCoockSMF', #if auth over SMF - same as SMF coockie 
	rem_cookie => 'MjAuthRem', #'remember_me' @ login data store
	sess_cookie => 'MjSession', 
	sess_cookie_php => 'PHPSESSID', 
	cookie_forever_time => '2147483647', #time
	guestuser_isactive => 1, #1:0. 0!!!, - defined() chk on it
	allow_sw_toslaveusers => 1, #1/0==undef #can sw to 'slave' user [* with same awp, but lower role seq]
	allow_sw_awproles => 1, #1/0==undef #can sw between awproles?
	default_reg_role => '0', #0 == guest
	
	#we can move permissions from db here (but it will be statically), 
	#so it will be 1 DB query less
	usr_permissions_prfedined => { 
		#role_id => {controller => action => {r/w = 1}}
		#u can &t_of($self->{'premissions'}) @ MjNCMS::User to make as current @ DB
		#after '${$self->{'premissions'}}{$res->{'controller'}} = {}... set'
		#
		#0 => { #guest
		#	
		#}
	}, 
	
	#http/client/locale settings
	site_html_lang => 'en', 
	site_xml_lang => 'en', 
	site_coding => 'utf-8', 
	site_coding => 'utf-8', 
	site_locale => 'en_US.UTF-8', 
	site_xmlenc => 'utf8', 
	site_name => 'MjNCMS', #default title
	site_contactemail => undef, #'some@else.wtf', 
	site_time_offset => 0, #default GMT time offset
	
	log_file => '/tmp/mj.log', 
	log_level => 'warn', #debug, info, warn, error, fatal, || ''/0 - disable ???
	
	#no end slash @ url's
	adm_url => '/mjadmin', #for possibility  to move /admin somewhere
	forum_url => '/forum', 
	userfiles_url => '/userfiles/mjncms', 
	
	#slash @ end, relative paths only
	tt_tpls_root => '../public_html/tt_tpls/mjncms/', 
	tt_tpls_paths => [
		'../public_html/tt_tpls/mjncms/', 
		'../public_html/tt_tpls/_common/', 
	], 
	#still no end slash @ url's 
	tt_tpls_theme_urlpath => '/tt_tpls/mjncms', 
	tt_plugins => {
		#'pod' => 'Template::Plugin::Pod',
		#'scalar' => 'Template::Plugin::Scalar',
		#'assert' => 'Template::Plugin::Assert',
		#'date' => 'Template::Plugin::Date',
		#'file' => 'Template::Plugin::File',
		#'table' => 'Template::Plugin::Table',
		#'dumper' => 'Template::Plugin::Dumper',
		#'directory' => 'Template::Plugin::Directory',
		#'latex' => 'Template::Plugin::Latex',
		#'dbi' => 'Template::Plugin::DBI',
		'html' => 'Template::Plugin::HTML',
		#'autoformat' => 'Template::Plugin::Autoformat',
		#'view' => 'Template::Plugin::View',
		#'xml' => 'Template::Plugin::XML',
		#'debug' => 'Template::Plugin::Debug',
		#'iterator' => 'Template::Plugin::Iterator',
		#'url' => 'Template::Plugin::URL',
		#'wrap' => 'Template::Plugin::Wrap',
		#'datafile' => 'Template::Plugin::Datafile',
		#'cgi' => 'Template::Plugin::CGI',
		#'image' => 'Template::Plugin::Image',
		#'format' => 'Template::Plugin::Format',
		#'xmlstyle' => 'Template::Plugin::XML::Style'
		'bytestream' => 'MjNCMS::Template::Filter::bytestream', 
		'loc' => 'MjNCMS::Template::Filter::loc', 
	},
	
	#tt_filterlist => {}, #if empty - faster just comment setting
	
	#path to static files (local path for url '/'), relative
	site_htmlstatic_root => '../public_html',
	
	#user static files, for file manager / personal filemanager, relative
	userfiles_path => '../public_html/userfiles/mjncms', 
	
	#Fast crypt and crc settings
	crypt_key => '<KEJ*#(J)@CSKAFDJ', #16 symbols enough - for crypt && decrypt smth fast && in easy way. JS decrypt also supported [ http://search.cpan.org/dist/Crypt-Tea/Tea.pm ]
	md_chk_key => ';giweJXE392CDasf ', #16 symbols enough - for checking smth data by CRC [for example some values going trough 2->n pages over browser && should be unchanged - set crc && verify :) ]
	cookie_sign_key => 'o*(EFC,eofpkj', #16 symbols enough - for signing cookies - default key is unsecure (since mojo 0.999922)
	
	#http://search.cpan.org/~gbarr/TimeDate-1.20/lib/Date/Format.pm
	#http://dev.mysql.com/doc/refman/5.1/en/date-and-time-functions.html
	#date::format/mysql date format
	site_langs => {
		'en' => {
			'name' => 'English', 
			#strptime fmt
			'date_fmt_full' => '%m.%d.%Y', 
			'date_fmt_hrs' => '%I:%M%p', 
			#mysql fmt
			'date_mfmt_full' => '%m.%d.%Y', 
			'date_mfmt_hrs' => '%I:%i%p', 
		}, 
		
	}, 
	#default site language
	site_lang_deft => 'en', 
	#memcache untranslated strings for future translation over web ui or smth [ see MjNCMS::I18N::loc() ]
	memc_untrans_strs => 0, #1/undef|0 
	
	#reCaptcha captcha settings: get own codes from http://recaptcha.net/
	recaptcha_publickey => 'fillit_fillit_fillti', 
	recaptcha_privatekey => 'fillit_fillit_fillti', 
	
	#allow &t_of(anything) dumper/debugger [chk MjNCMS::Service::t_of]
	allow_t_of => 0, 
	
	#Powered-By Header
	site_powered_by => 'MjNCMS', 
	site_extra_headers => {
		'X-Mojo-Env' => 'MjNCMS', #please left this
	}, 
	
	#for multi-site site-specific routines
	preroute_calls => [
		#{
		#	'controller' => 'MjNCMS::TestExtraCall', #which module, MjNCMS::TestExtraCall - working example
		#	'action' => 'make_extra_run', #which function
		#	'args' => { #argumets to function
		#		'oyaebu'=>'mylovelykey',
		#		'comeget'=>'some',
		#	}, 
		#}, 
	], 
	
	#for multi-site site-specific routines
	postroute_calls => [
		#{
		#	'controller' => 'MjNCMS::TestExtraCall', #which module, MjNCMS::TestExtraCall - working example
		#	'action' => 'make_extra_run', #which function
		#	'args' => { #argumets to function
		#		'oyaebu'=>'mylovelykey',
		#		'comeget'=>'some',
		#	}, 
		#}, 
	], 
	
	site_notify_msgs => {
		#'short_msg_code' => 'full phrase', 
		#'some' => 'get some', 
		#'cat_was_saved' => 'Category was saved.', 
	}, 
	
	#defaults for "paging" @ lists (list of usrts, content pages, etc)
	pager_itemsperpage => 25, 
	pager_maxcols => 10, 
	pager_pagearg => 'page', 
	
	robots_noindex => undef, #use noindex by default @tpl
	robots_nofollow => undef,  #use nofollow by default @tpl
	
	content_archive_pages => 1, #1/0: before apply edited page - save backup to archive table?
	
	short_urls_allow_multialias => 0, #0/1 - allow create multi aliases for same url. exists returns instead.
	
	#register function call rules, for current 'tt_controller'/'tt_action', '*' ==> *anything*
	reg_tt_call_rules => {
		'*' => {
			'*' => {
				
			},
		},
		admin => {
			'*' => {
				'Menus' => {
					'menus_get_record_tree' => 1, 
					'menus_get_record' => 1, 
					'menus_get_parent_tree' => 1,
					'menus_get_transes' => 1,
					
				}
			},
			
		}
	}
	
);

sub get_config ($) {
	
	my $host = shift;
	return undef unless $host && length $host;
	
	#no 'www.' and final '/'
	$host =~ s/^www\.|\/$//;
	my %cfg_alternatives;
	
	$cfg_alternatives{'mojotest'} = {
		databases_write => {
			common => [#common is default dbh connection grp
				{
					dbh_host => 'localhost', 
					dbh_port => '3306', 
					dbh_user => 'mojotest', 
					dbh_pass => 'mojotest', 
					dbh_base => 'mojotest', 
				}
			],
			
		},

		#memcached settings
		memd_vars_prefix => 'mjt:', #deft prefix
		memd_servers => {
			common => {
				servers => [ 
					{ address => 'localhost:11211', weight => 2.5 },

				],
			}, 
			#more memd server groups
		},
		
		auth_engine => 'smf', 
		auth_cookie => 'MjtCoockSMF', #if auth over SMF - same as SMF coockie 
		rem_cookie => 'MjtAuthRem', #'remember_me' @ login data store
		sess_cookie => 'MjtSession', 

		#http/client/locale settings
		site_html_lang => 'ru', 
		site_xml_lang => 'ru', 
		site_coding => 'utf-8', #windows-1251
  		site_locale => 'ru_RU.UTF-8', #Russian_Russia.1251
  		site_xmlenc => 'utf8', #cp1251
  		site_name => 'MjNCMS Demo site', #default title
  		site_contactemail => 'ffl.public@gmail.com', 
  		site_time_offset => 3, #default GMT time offset
  		
  		#Fast crypt and crc settings
  		crypt_key => 'IfteISZ8d(%82cdn', 
  		md_chk_key => 'wadO*EWYDHcxoew;', 
  		cookie_sign_key => '_d+@OYAEBU!@*DSs', 
  		
  		site_langs => {
			'ru' => {
				'name' => 'Russian', 
				#'locale' => 'ru_RU.UTF-8', #or site_locale
				#strptime fmt
				'date_fmt_full' => '%d.%m.%Y', 
				'date_fmt_hrs' => '%H:%M', 
				#mysql fmt
				'date_mfmt_full' => '%d.%m.%Y', 
				'date_mfmt_hrs' => '%H:%i', 
			}, 
			'en' => {
				'name' => 'English', 
				#'locale' => 'en_US.UTF-8', #or site_locale
				#strptime fmt
				'date_fmt_full' => '%m.%d.%Y', 
				'date_fmt_hrs' => '%I:%M%p', 
				#mysql fmt
				'date_mfmt_full' => '%m.%d.%Y', 
				'date_mfmt_hrs' => '%I:%i%p', 
			}, 
			
		}, 
		#default site language
		site_lang_deft => 'ru', 
		#memcache untranslated strings for future translation over web ui or smth [ see MjNCMS::I18N::loc() ]
		memc_untrans_strs => 1, #1/undef|0 

		#reCaptcha captcha settings: get own codes from http://recaptcha.net/
		recaptcha_publickey => '6LetMQsAAAAAAEJwBmMo17i2H2DqycX6-IDyBxc3', 
		recaptcha_privatekey => '6LetMQsAAAAAANWDOQ1FaWSuTmHWQ83aMs43GqB3', 
  		
  		#allow &t_of(anything) dumper/debugger [chk MjNCMS::Service::t_of]
  		allow_t_of => 1,
  		
	};
	
	$cfg_alternatives{'mojotest:82'} = 
		$cfg_alternatives{'mojotest:3000'} = 
			$cfg_alternatives{'mojotest'} ;
	
	return {%CFG_COMMON, %{$cfg_alternatives{$host}}} if $cfg_alternatives{$host};
	return undef;
	
}

1;
