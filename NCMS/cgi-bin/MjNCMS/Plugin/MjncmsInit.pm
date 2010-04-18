package MjNCMS::Plugin::MjncmsInit;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Bender: Behold... the Internet.
#
# (c) Futurama
#
#
#
#                        `. ___
#                       __,' __`.                _..----....____
#           __...--.'``;.   ,.   ;``--..__     .'    ,-._    _.-'
#     _..-''-------'   `'   `'   `'     O ``-''._   (,;') _,'
#   ,'________________                          \`-._`-','
#    `._              ```````````------...___   '-.._'-:
#       ```--.._      ,.                     ````--...__\-.
#               `.--. `-`                       ____    |  |`
#                 `. `.                       ,'`````.  ;  ;`
#                   `._`.        __________   `.      \'__/`
#                      `-:._____/______/___/____`.     \  `
#                                  |       `._    `.    \
#                                  `._________`-.   `.   `.___
#                                                SSt  `------'`
#
#

use common::sense;
use base 'Mojolicious::Plugin';

use FindBin;
use lib "$FindBin::Bin/../../";

use MjNCMS::Config qw/:subs :vars /;
use MjNCMS::Service qw/:subs /;

use MjNCMS::MjI18N;
use MjNCMS::User;
use MjNCMS::Date;

use Mojo::Headers;
use Mojo::Loader;
use Mojo::URL;


#C-based memcached api
use Cache::Memcached::Fast;

#Fast and safe captcha outsorcing service [ GD::SecurityImage may be later - but load cpu more ]
use Captcha::reCAPTCHA;

#4 Session store @memcache/database
use Data::Serializer;

sub register {
    my ($self, $app, $args) = @_;
    $args ||= {};

    #init MjNCMS env:
    $app->plugins->add_hook(
        before_dispatch => sub {
            #it's now also @daemon mode works for static files - hk later how tp skip
            my ($self, $c) = @_;
            $SESSION{'REDIR'} = undef; #redirect over plugin;

            my $server_scheme = $c->tx->req->url->base->scheme;
            my $server_name = $c->tx->req->url->base->host;
            my $server_port = $c->tx->req->url->base->port;
            
            if (!$server_name || $server_name !~ /\w+/) {
                $SESSION{'REDIR'} = '/_static/msg/no_server.shtml';
                return 0;
            }
            
            #multi-site thing :)
            my $cfg = &get_config($server_name . ((scalar $server_port)? ':'.$server_port:''));#from MjNCMS::Config
            unless ($cfg && ref $cfg) {
                $SESSION{'REDIR'} = '/_static/msg/no_cfg.shtml';
                return 0;
            }
            
            $SESSION{'ADM_URL'} = $$cfg{'adm_url'} || '/mjadmin';
            $SESSION{'USR_URL'} = $$cfg{'usr_url'} || '/user';
            $SESSION{'SHORTLINKS_URL'} = $$cfg{'shortlinks_url'} ||  '/sl';
            $SESSION{'SHORTLINKS_REDIR_URL'} = $$cfg{'shortlinks_url'} ||  '/r';
            $SESSION{'FORUM_URL'} = $$cfg{'forum_url'} || undef;
            
            $SESSION{'THEME_URLPATH'} = $$cfg{'tt_tpls_theme_urlpath'} || '/tt_tpls/mjcms';
            
            $SESSION{'SITE_URL_EXTENSIONS'} = $$cfg{'site_url_extensions'}
                if $$cfg{'site_url_extensions'};
            foreach my $ext (keys %{$SESSION{'SITE_URL_EXTENSIONS'}}){
                $SESSION{'EXTENSIONS_' . uc($ext)} = ${$SESSION{'SITE_URL_EXTENSIONS'}}{$ext};
            }
            
            $SESSION{'USERFILES_URL'} = $$cfg{'userfiles_url'} || '/userfiles';
            $SESSION{'USERFILES_PATH'} = $$cfg{'userfiles_path'} || '../public_html/userfiles', ;
            
            my (
                $dbh_id, $dbh_rand, 
                $dbh_settings_set, 
                $dbh_settings, 
                $memd_id, 
            );
            
            $SESSION{'SERVER_SCHEME'} = $server_scheme;
            $SESSION{'SERVER_NAME'} = $server_name;
            $SESSION{'SERVER_PORT'} = $server_port;
            $SESSION{'SERVER_URL'} = $SESSION{'SERVER_SCHEME'} . '://' . $SESSION{'SERVER_NAME'};
            $SESSION{'SERVER_URL'} .= ':'.$SESSION{'SERVER_PORT'} if ( 
                (scalar $SESSION{'SERVER_PORT'}) && 
                (scalar $SESSION{'SERVER_PORT'} != 80) 
            );

            $SESSION{'ALLOW_T_OF'} = $$cfg{'allow_t_of'} if $$cfg{'allow_t_of'};#sub t_of(anything) 2file dumper MjNCMS::Service::t_of

            $$cfg{'log_level'} = defined($$cfg{'log_level'})? $$cfg{'log_level'}:'warn';
            $SESSION{'LOG'} = $c->app->log;
            if ($$cfg{'log_level'}) {
                $SESSION{'LOG'}->path($$cfg{'log_file'});
                $SESSION{'LOG'}->level($$cfg{'log_level'});
            }
            else {
                binmode STDERR, ':utf8';
                $SESSION{'LOG'}->path(\*STDERR);
                $SESSION{'LOG'}->level(0);
            }
            
            $SESSION{'SITE_LOCALE'} = $$cfg{'site_locale'} || 'en_US.UTF-8';
            
            $SESSION{'SITE_CONTACTEMAIL'} = $$cfg{'site_contectemail'} if $$cfg{'site_contectemail'};
            $SESSION{'SITE_TIME_OFFSET'} = $$cfg{'site_time_offset'} || 0;
            
            $$cfg{'site_coding'} = 'utf-8' unless $$cfg{'site_coding'};
            $SESSION{'SITE_CODING'} = $$cfg{'site_coding'};
            $$cfg{'site_powered_by'} = 'MjNCMS - Mojolicious Perl CMS' unless $$cfg{'site_powered_by'};
            $c->tx->res->headers->header('X-Powered-By' => $$cfg{'site_powered_by'});
            $c->tx->res->headers->header('Content-Type' => 'text/html; charset='.$$cfg{'site_coding'});
            if ($$cfg{'site_extra_headers'} && ref $$cfg{'site_extra_headers'} && ref $$cfg{'site_extra_headers'} eq 'HASH') {
                foreach my $header (keys %{$$cfg{'site_extra_headers'}}) {
                    $c->tx->res->headers->header($header => ${$$cfg{'site_extra_headers'}}{$header});
                }
            }
            $c->app->renderer->encoding($$cfg{'site_coding'}) if $$cfg{'site_coding'};
            
            if ($$cfg{'tt_tpls_root'}) {
                $c->app->renderer->root($$cfg{'tt_tpls_root'});
            }
            else {
                $c->app->renderer->root('../public_html/tt_tpls/mjcms');
            }
            
            @{$TT_CFG{'includepath'}} = ();
            %{$TT_CFG{'filterlist'}} = ();
            push @{$TT_CFG{'includepath'}}, @{$$cfg{'tt_tpls_paths'}};
            $TT_CFG{'filterlist'} = $$cfg{'tt_filterlist'} if ($$cfg{'tt_filterlist'} && ref $$cfg{'tt_filterlist'} && ref $$cfg{'tt_filterlist'} eq 'HASH');
            
            $TT_CFG{'plugins'} = $$cfg{'tt_plugins'} if ($$cfg{'tt_plugins'} && ref $$cfg{'tt_plugins'} && ref $$cfg{'tt_plugins'} eq 'HASH');
            
            $SESSION{'REG_TT_CALL_RULES'} = $$cfg{'reg_tt_call_rules'} if ($$cfg{'reg_tt_call_rules'} && ref $$cfg{'reg_tt_call_rules'} && ref $$cfg{'reg_tt_call_rules'} eq 'HASH');
            
            %TT_VARS = (
                html_lang => $$cfg{'site_html_lang'}? $$cfg{'site_html_lang'}:'en',
                xml_lang => $$cfg{'site_xml_lang'}? $$cfg{'site_xml_lang'}:'en',
                html_charset => $$cfg{'site_coding'}? $$cfg{'site_coding'}:'utf-8',
                CSS => [], 
                JS => [], 
                site_name => $$cfg{'site_name'}? $$cfg{'site_name'}:'MjNCMS',
                
                robots_noindex => $$cfg{'robots_noindex'}? 1:0, 
                robots_nofollow => $$cfg{'robots_nofollow'}? 1:0, 
                
            );
            %TT_CALLS = (
                sort_jscss => \&sv_sort_jscss, 
                inarray => \&inarray, 
                register_tt_call => \&sv_register_tt_call, 
                
            );

            $c->app->static->root($$cfg{'site_htmlstatic_root'}) if $$cfg{'site_htmlstatic_root'};
            
            $SESSION{'CONTENT_ARCHIVE_PAGES'} = $$cfg{'content_archive_pages'} || 0;
            
            $SESSION{'REQ'} = $c->req;
            $SESSION{'REFERER'} = $SESSION{'REQ'}->param('referer');

            #if claster/multidb try get last written server and use if exactly
            if (
                $SESSION{'DBH_MASTER_AFTERPOST'} = $$cfg{'dbh_master_afterpost_allow'} && 
                $SESSION{'REQ'}->param('dbh') =~ /^master(\d+)?$/ 
            ) {
                    $dbh_rand = $1 if defined $1 && length $1;
            }
            
            #info message hint like 'smth was saved', etc
            if ($SESSION{'REQ'}->param('msg')) {
                #raw text msg
                $TT_VARS{'MSG'} = $SESSION{'REQ'}->param('msg');
            }
            elsif (
                #predefined msg by short code
                $SESSION{'REQ'}->param('ntf') && 
                $$cfg{'site_notify_msgs'} && 
                ref $$cfg{'site_notify_msgs'} &&
                ref $$cfg{'site_notify_msgs'} eq 'HASH'
            ) {
                $TT_VARS{'MSG'} = ${$$cfg{'site_notify_msgs'}}{$SESSION{'REQ'}->param('ntf')};
            }
            
            $SESSION{'COOKIES_RES'} = {};#hash with cookies @responce [values will be push @tx->res->cookies() @end]
            $SESSION{'COOKIES_REQ'} = {};#hash with cookies @request name=cookie
            foreach my $cookie (@{$c->tx->req->cookies}) {
                $cookie->value($SESSION{'BS'}($cookie->value())->url_unescape()->to_string()) if $cookie->value();
                ${$SESSION{'COOKIES_REQ'}}{$cookie->name} = $cookie;
            }
            $SESSION{'HTTP_REFERER'} = ${$SESSION{'REQ'}->env}{'HTTP_REFERER'};
            $SESSION{'HTTP_USER_AGENT'} = ${$SESSION{'REQ'}->env}{'HTTP_USER_AGENT'};#used @ smf auth
            $SESSION{'REMOTE_ADDR'} = ${$SESSION{'REQ'}->env}{'REMOTE_ADDR'};#used @ recaptcha #no this envs @ 'daemon' test mode
            
            #Set this depends how you JS framework rly marks ajax requests 
            $SESSION{'REQ_ISAJAX'} = undef;
            if($SESSION{'REQ'}->headers->header('X-Requested-With') && 
                $SESSION{'REQ'}->headers->header('X-Requested-With') eq 'XMLHttpRequest') {
                    #[this is at least for mootools]
                    $SESSION{'REQ_ISAJAX'} = 1;
            }
            elsif(undef){
                #some another rules
            }
                
            $SESSION{'CURRENT_PAGE'} = $c->tx->req->url->clone; #->to_string;
            $SESSION{'CURRENT_PAGE'}->query->remove('rnd');
            $SESSION{'CURRENT_PAGE'}->query->remove('notifyid');
            $SESSION{'CURRENT_PAGE'}->query->remove('msg');
            $SESSION{'CURRENT_PAGE'}->query->remove('dbh');
            
            #dbh lottery
            if(
                defined($$cfg{'databases_write'}) && 
                ref $$cfg{'databases_write'} && 
                ref $$cfg{'databases_write'} eq 'HASH'
            ) {
                foreach my $dbh_grp (keys %{$$cfg{'databases_write'}}){
                    $dbh_id = 'DBH';
                    $dbh_id .= '_'.(uc $dbh_grp) unless $dbh_grp eq 'common';
                    
                    if (
                        defined(${$$cfg{'databases_write'}}{$dbh_grp}) && 
                        ref ${$$cfg{'databases_write'}}{$dbh_grp} && 
                        ref ${$$cfg{'databases_write'}}{$dbh_grp} eq 'ARRAY' && 
                        scalar @{${$$cfg{'databases_write'}}{$dbh_grp}} 
                    ) {
                        $dbh_settings_set = ${$$cfg{'databases_write'}}{$dbh_grp};
                        while (scalar @{$dbh_settings_set}) {
                            $dbh_rand = (
                                defined($dbh_rand) && 
                                $dbh_rand =~ /^\d+$/ && 
                                $dbh_rand <= (scalar @{$dbh_settings_set} - 1)
                            )? $dbh_rand:int(rand(scalar @{$dbh_settings_set}));
                            $dbh_settings = ${$dbh_settings_set}[$dbh_rand];
                            delete ${$dbh_settings_set}[$dbh_rand];
                            
                            $SESSION{$dbh_id} = 
                                $SESSION{$dbh_id.'_W'} = &get_dbh(
                                    $$dbh_settings{'dbh_host'}, 
                                    $$dbh_settings{'dbh_port'}, 
                                    $$dbh_settings{'dbh_base'}, 
                                    $$dbh_settings{'dbh_user'}, 
                                    $$dbh_settings{'dbh_pass'}, 
                                    $$cfg{'dbh_enc'}
                                );
                            
                            next unless $SESSION{$dbh_id};
                            
                            $SESSION{'DBH_MASTER_AFTERPOST'} = $dbh_rand+1;
                            $SESSION{$dbh_id.'_W'}->do('SET NAMES '.($SESSION{'DBH'}->quote($$cfg{'dbh_enc'})).';') if $$cfg{'dbh_enc'};
                            last;
                        }
                        $dbh_rand = undef;#one master many slaves
                    }
                    
                    if (
                        !(
                            $SESSION{'DBH_MASTER_AFTERPOST'} = $$cfg{'dbh_master_afterpost_allow'} && 
                            $SESSION{'REQ'}->param('dbh') =~ /^master(\d+)?$/ 
                        ) &&
                        defined($$cfg{'databases_read'}) && 
                        ref $$cfg{'databases_read'} && 
                        ref $$cfg{'databases_read'} eq 'HASH' && 
                        defined(${$$cfg{'databases_read'}}{$dbh_grp}) && 
                        ref ${$$cfg{'databases_read'}}{$dbh_grp} && 
                        ref ${$$cfg{'databases_read'}}{$dbh_grp} eq 'ARRAY' && 
                        scalar @{${$$cfg{'databases_read'}}{$dbh_grp}} 
                    ) {
                        $dbh_settings_set = ${$$cfg{'databases_read'}}{$dbh_grp};
                        while (scalar @{$dbh_settings_set}) {
                            $dbh_rand = (defined($dbh_rand) && $dbh_rand <= (scalar @{$dbh_settings_set} - 1))? $dbh_rand:int(rand(scalar @{$dbh_settings_set}));
                            $dbh_settings = ${$dbh_settings_set}[$dbh_rand];
                            delete ${$dbh_settings_set}[$dbh_rand];
                        
                            $SESSION{$dbh_id.'_R'} = &get_dbh(
                                $$dbh_settings{'dbh_host'}, 
                                $$dbh_settings{'dbh_port'}, 
                                $$dbh_settings{'dbh_base'}, 
                                $$dbh_settings{'dbh_user'}, 
                                $$dbh_settings{'dbh_pass'},
                                $$cfg{'dbh_enc'}
                            );
                            
                            next unless $SESSION{$dbh_id.'_R'};
                            
                            $SESSION{'DBH_MASTER_AFTERPOST'} = $dbh_rand+1 unless $SESSION{'DBH_MASTER_AFTERPOST'};
                            $SESSION{$dbh_id.'_R'}->do('SET NAMES '.($SESSION{'DBH'}->quote($$cfg{'dbh_enc'})).';') if $$cfg{'dbh_enc'};
                            last;
                        }
                    }
                    elsif ($SESSION{$dbh_id.'_W'}) {
                        $SESSION{$dbh_id.'_R'} = $SESSION{$dbh_id.'_W'};
                    }
                    
                    if(
                        (
                            !$SESSION{$dbh_id.'_R'} || 
                            !$SESSION{$dbh_id.'_W'}
                        ) && 
                        defined($$cfg{'databases_reserve'}) && 
                        ref $$cfg{'databases_reserve'} && 
                        ref $$cfg{'databases_reserve'} eq 'HASH' && 
                        defined(${$$cfg{'databases_reserve'}}{$dbh_grp}) && 
                        ref ${$$cfg{'databases_reserve'}}{$dbh_grp} && 
                        ref ${$$cfg{'databases_reserve'}}{$dbh_grp} eq 'ARRAY' && 
                        scalar @{${$$cfg{'databases_reserve'}}{$dbh_grp}} 
                    ) {
                        $dbh_settings_set = ${$$cfg{'databases_reserve'}}{$dbh_grp};
                        
                        if (!$SESSION{$dbh_id.'_R'} && $SESSION{$dbh_id.'_W'}) {
                            $SESSION{$dbh_id.'_R'} = 
                                $SESSION{$dbh_id.'_W'};
                            $SESSION{'DBHS_ISRESERVE'} = [] unless defined $SESSION{'DBHS_ISRESERVE'};
                            push @{$SESSION{'DBHS_ISRESERVE'}}, $dbh_grp.'_R';
                        }
                        elsif (!$SESSION{$dbh_id.'_W'} && $SESSION{$dbh_id.'_R'}) {
                            $SESSION{$dbh_id} = 
                                $SESSION{$dbh_id.'_W'} = 
                                    $SESSION{$dbh_id.'_R'};
                            $SESSION{'DBHS_ISRESERVE'} = [] unless defined $SESSION{'DBHS_ISRESERVE'};
                            push @{$SESSION{'DBHS_ISRESERVE'}}, $dbh_grp.'_W';
                        }
                        else{
                            while (scalar @{$dbh_settings_set}) {
                                $dbh_rand = ($dbh_rand <= (scalar @{$dbh_settings_set} - 1))? $dbh_rand:int(rand(scalar @{$dbh_settings_set}));
                                $dbh_settings = ${$dbh_settings_set}[$dbh_rand];
                                delete ${$dbh_settings_set}[$dbh_rand];

                                $SESSION{$dbh_id} = 
                                    $SESSION{$dbh_id.'_W'} =                            
                                        $SESSION{$dbh_id.'_R'} = &get_dbh(
                                            $$dbh_settings{'dbh_host'}, 
                                            $$dbh_settings{'dbh_port'}, 
                                            $$dbh_settings{'dbh_base'}, 
                                            $$dbh_settings{'dbh_user'}, 
                                            $$dbh_settings{'dbh_pass'}, 
                                            $$cfg{'dbh_enc'}
                                        );
                                
                                next unless $SESSION{$dbh_id.'_R'};
                                
                                $SESSION{'DBH_MASTER_AFTERPOST'} = $dbh_rand+1 unless $SESSION{'DBH_MASTER_AFTERPOST'};
                                $SESSION{$dbh_id}->do('SET NAMES '.($SESSION{'DBH'}->quote($$cfg{'dbh_enc'})).';') if $$cfg{'dbh_enc'};
                                last;
                            }
                            
                            $SESSION{'DBHS_ISRESERVE'} = [] unless defined $SESSION{'DBHS_ISRESERVE'};
                            push @{$SESSION{'DBHS_ISRESERVE'}}, ($dbh_grp.'_W', $dbh_grp.'_R');
                        }
                    }
                    
                    unless ($SESSION{$dbh_id}) {
                        $SESSION{'REDIR'} = '/_static/msg/no_dbh.shtml?conn_id='.$dbh_id;
                        return 0;
                    }
                }
            }

            unless ($SESSION{'DBH'}) {
                $SESSION{'REDIR'} = '/_static/msg/no_dbh.shtml?conn_id=DBH';
                return 0;
            }
            
            if (
                defined($$cfg{'memd_servers'}) && 
                ref $$cfg{'memd_servers'} && 
                ref $$cfg{'memd_servers'} eq 'HASH'
            ) {
                foreach my $memd_grp (keys %{$$cfg{'memd_servers'}}){
                    $memd_id = 'MEMD';
                    $memd_id .= '_'.(uc $memd_grp) unless $memd_grp eq 'common';
                    
                    $SESSION{$memd_id} = new Cache::Memcached::Fast({
                        servers => ${${$$cfg{'memd_servers'}}{$memd_grp}}{'servers'},
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
                        max_size => 1024 * 1024, #1Mb is max, per key
                    }) if (
                        ${${$$cfg{'memd_servers'}}{$memd_grp}}{'servers'} && 
                        ref ${${$$cfg{'memd_servers'}}{$memd_grp}}{'servers'} && 
                        ref ${${$$cfg{'memd_servers'}}{$memd_grp}}{'servers'} eq 'ARRAY'
                    );

                    $SESSION{$memd_id} -> namespace(
                        ${${$$cfg{'memd_servers'}}{$memd_grp}}{'vars_prefix'}? 
                            ${${$$cfg{'memd_servers'}}{$memd_grp}}{'vars_prefix'}:$$cfg{'memd_vars_prefix'}
                            ) if (
                                $SESSION{$memd_id} && 
                                (
                                    ${${$$cfg{'memd_servers'}}{$memd_grp}}{'vars_prefix'} || 
                                    $$cfg{'memd_vars_prefix'}
                                )
                            );

                }
            }
            
            $SESSION{'PAGER_ITEMSPERPAGE'} = $$cfg{'pager_itemsperpage'} || 25, 
            $SESSION{'PAGER_MAXCOLS'} = $$cfg{'pager_maxcols'} || 10, 
            $SESSION{'PAGER_PAGEARG'} = $$cfg{'pager_pagearg'} || 'page', 
            
            $SESSION{'PREFIX'} = $$cfg{'dbh_prefix'} || '';
            $SESSION{'FORUM_PREFIX'} = $$cfg{'dbh_forum_prefix'} || '';
            
            $SESSION{'RND'} = sprintf "%05u", rand 100000;
            $SESSION{'PAGE_CACHABLE'} = undef;

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
            
            $c->app->secret($SESSION{'COOKIE_SIGN_KEY'});
            
            $SESSION{'SITE_LANGS'} = (
                $$cfg{'site_langs'} && 
                ref $$cfg{'site_langs'} && 
                ref $$cfg{'site_langs'} eq 'HASH'
                )? $$cfg{'site_langs'}:{'en' => 'MjNCMS/Locales/mjcms_en.po'};
            
            unless (scalar keys %{$SESSION{'SITE_LANGS'}}) {
                $SESSION{'REDIR'} = '/_static/msg/no_lang.shtml';
                return 0;
            }
            
            $SESSION{'SITE_LANG_DEFT'} = $$cfg{'site_lang_deft'}? $$cfg{'site_lang_deft'}:${[keys %{$SESSION{'SITE_LANGS'}}]}[0];
            $SESSION{'MEMC_UNTRANS_STRS'} = $$cfg{'memc_untrans_strs'}? $$cfg{'memc_untrans_strs'}:undef;
                
            $SESSION{'LOC'} = MjNCMS::MjI18N->new($c);
            unless ($SESSION{'LOC'} -> init_langs($SESSION{'SITE_LANGS'})) {
                $SESSION{'REDIR'} = '/_static/msg/no_lang.shtml';
                return 0;
            }
            
            $SESSION{'AUTH_ENGINE'} = $$cfg{'auth_engine'} || 'smf';
            $SESSION{'AUTH_COOKIE'} = $$cfg{'auth_cookie'} || 'SMFCookie762';
            $SESSION{'REM_COOKIE'} = $$cfg{'rem_cookie'} || 'MjtAuthRem';
            $SESSION{'SESS_COOKIE'} = $$cfg{'sess_cookie'} || 'MjtSession';
            $SESSION{'SESS_COOKIE_PHP'} = $$cfg{'sess_cookie_php'} || 'PHPSESSID';
            $SESSION{'COOKIE_FOREVER_TIME'} = $$cfg{'cookie_forever_time'} || (time() + 155520000);#smw 5 years later
            $SESSION{'GUESTUSER_ISACTIVE'} = defined($$cfg{'guestuser_isactive'})? $$cfg{'guestuser_isactive'}:1;
            $SESSION{'DEFAULT_REG_ROLE'} = $$cfg{'default_reg_role'} || '0';
            
            $SESSION{'ADMIN_PANEL_ROLES'} = $$cfg{'admin_panel_roles'} || [1, ];#1==Admins
            $SESSION{'ADMIN_PANEL_AWPS'} = $$cfg{'admin_panel_awps'} || [1, ];#1==Admins::Superadmin
            
            $SESSION{'ALLOW_SW_TOSLAVEUSERS'} = $$cfg{'allow_sw_toslaveusers'} || 0;
            $SESSION{'ALLOW_SW_AWPROLES'} = $$cfg{'allow_sw_awproles'} || 0;

            $SESSION{'SESSION_PHP'} = 
                ${$SESSION{'COOKIES_REQ'}}{$SESSION{'SESS_COOKIE_PHP'}} 
                if ${$SESSION{'COOKIES_REQ'}}{$SESSION{'SESS_COOKIE_PHP'}};
            
            $SESSION{'USR_PERMISSIONS_PREFEDINED'} = $$cfg{'usr_permissions_prfedined'} 
                if $$cfg{'usr_permissions_prfedine'} && 
                 ref $$cfg{'usr_permissions_prfedine'} && 
                    ref $$cfg{'usr_permissions_prfedine'} eq 'HASH' && 
                        scalar keys %{$$cfg{'usr_permissions_prfedine'}};
            
            $SESSION{'USR'} = MjNCMS::User->new($c, $SESSION{'AUTH_ENGINE'});
            unless ($SESSION{'USR'}){
                $SESSION{'REDIR'} = '/_static/msg/no_usr.shtml';
                return 0;
            }
            unless($SESSION{'USR'} -> auth()){
                $SESSION{'REDIR'} = '/_static/msg/no_auth.shtml'.'?state='. ($SESSION{'USR'} -> {'last_state'});
                return 0;
            }
            #&t_of('e',$SESSION{'LOC'}->{'CURRLANG'}, $SESSION{'USR'}->{'member_sitelng'},'e');
            if($SESSION{'USR'}->{'member_sitelng'} && 
                $SESSION{'USR'}->{'member_sitelng'} ne $SESSION{'LOC'}->{'CURRLANG'} && 
                &inarray([keys %{$SESSION{'SITE_LANGS'}}], $SESSION{'USR'}->{'member_sitelng'})){
                    $SESSION{'LOC'}->set_lang($SESSION{'USR'}->{'member_sitelng'});
            }
            else{
                $SESSION{'USR'}->{'member_sitelng'} = $SESSION{'LOC'}->{'CURRLANG'}; #==$SESSION{'SITE_LANG_DEFT'};
            }
            
            $SESSION{'DATE'} = MjNCMS::Date->new();
            
            $SESSION{'SHORT_URLS_ALLOW_MULTIALIAS'} = $$cfg{'short_urls_allow_multialias'} || 0;
            
            $SESSION{'PREROUTE_CALLS'} = $$cfg{'preroute_calls'} if (
                $$cfg{'preroute_calls'} && 
                    ref $$cfg{'preroute_calls'} && 
                        ref $$cfg{'preroute_calls'} eq 'ARRAY' );
                        
            $SESSION{'POSTROUTE_CALLS'} = $$cfg{'postroute_calls'} if (
                $$cfg{'postroute_calls'} && 
                    ref $$cfg{'postroute_calls'} && 
                        ref $$cfg{'postroute_calls'} eq 'ARRAY' );
            
            return 1;
            
        }
        
    );

    #run extra calls [site-specific] before dispatch
    $app->plugins->add_hook(
        before_dispatch => sub {
            my ($self, $c) = @_;

            if(
                $SESSION{'PREROUTE_CALLS'} && 
                ref $SESSION{'PREROUTE_CALLS'} &&
                ref $SESSION{'PREROUTE_CALLS'} eq 'ARRAY' &&
                scalar @{$SESSION{'PREROUTE_CALLS'}}
            ){
                foreach my $call (@{$SESSION{'PREROUTE_CALLS'}}){

                    next unless (
                        $call && ref $call && ref $call eq 'HASH' &&
                        length $$call{'controller'} && length $$call{'action'}
                    );
                    
                    my $args = $$call{'args'}? $$call{'args'}:undef;
                    my $module = "${$call}{'controller'}";
                    my $action = "${$call}{'action'}";

                    my $e = Mojo::Loader->load($module);
                    next if $e;

                    next unless $module->can('new') && $module->can($action);
                    return $module->new($c)->$action($args);
                }
            }
        }
    );


    #run extra calls [site-specific] after dispatch
    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;

            if(
                $SESSION{'POSTROUTE_CALLS'} && 
                ref $SESSION{'POSTROUTE_CALLS'} &&
                ref $SESSION{'POSTROUTE_CALLS'} eq 'ARRAY' &&
                scalar @{$SESSION{'POSTROUTE_CALLS'}}
            ){
                foreach my $call (@{$SESSION{'POSTROUTE_CALLS'}}){

                    next unless (
                        $call && ref $call && ref $call eq 'HASH' &&
                        length $$call{'controller'} && length $$call{'action'}
                    );
                    
                    my $args = $$call{'args'}? $$call{'args'}:undef;
                    my $module = "${$call}{'controller'}";
                    my $action = "${$call}{'action'}";

                    my $e = Mojo::Loader->load($module);
                    next if $e;

                    next unless $module->can('new') && $module->can($action);
                    return $module->new($c)->$action($args);
                }
            }
        }
    );

    #finish session (close session.set cookies, etc)
    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;
            if (scalar keys %{$SESSION{'COOKIES_RES'}}) {
                foreach my $cookie (values %{$SESSION{'COOKIES_RES'}}) {
                    $cookie->value($SESSION{'BS'}($cookie->value())->url_escape()->to_string()) if $cookie->value();
                    $cookie->comment($SESSION{'BS'}($cookie->comment())->url_escape()->to_string()) if $cookie->comment();
                    $c->tx->res->cookies($cookie);
                }
                if ($SESSION{'PAGE_CACHABLE'}) {
                    $c->tx->res->headers->header('Cache-Control' => 'private, max-age=315360000');
                }
                else {
                    $c->tx->res->headers->header('Cache-Control' => 'private, no-cache');
                }
            }
            
            #"easy/lazy" redirects
            my (
                $url, $notify, $msg, 
                $m_dbh, $no_rnd, $extraparams, 
                
            );
            if($SESSION{'REDIR'}){
                if (ref $SESSION{'REDIR'} && ref $SESSION{'REDIR'} eq 'HASH'){
                    $url = ${$SESSION{'REDIR'}}{'url'};
                    $notify = ${$SESSION{'REDIR'}}{'notify'} && !${$SESSION{'REDIR'}}{'msg'};
                    $msg = ${$SESSION{'REDIR'}}{'msg'};
                    $extraparams = ${$SESSION{'REDIR'}}{'extraparams'};
                    $m_dbh = ${$SESSION{'REDIR'}}{'m_dbh'};
                    $no_rnd = ${$SESSION{'REDIR'}}{'no_rnd'};
                }
                else {
                    $url = $SESSION{'REDIR'};
                }
                $url = $SESSION{'SERVER_URL'} . $url unless $url =~ /^\w+\:\/\//;
                $url = Mojo::URL->new($url);
                $url->query->remove('rnd');
                $url->query->remove('notifyid');
                $url->query->remove('msg');
                $url->query->remove('dbh');
                $url->query->append(rnd => $SESSION{'RND'}) unless $no_rnd;
                $url->query->append(ntf => $notify) if $notify && $notify =~ /^\w+$/;
                $url->query->append(msg => $msg) if $msg;
                $url->query->append(dbh => 'master'.($SESSION{'DBH_MASTER_AFTERPOST'} - 1)) if (
                    (
                        $m_dbh && 
                        $SESSION{'DBH_MASTER_AFTERPOST'}
                    ) || 
                    (
                        $SESSION{'DBH_MASTER_AFTERPOST'} &&
                        $SESSION{'DBH_MASTER_AFTERPOST'} =~ /^\d+$/ &&
                        $SESSION{'REQ'}->method() eq 'POST' 
                    )
                );
                
                if($extraparams && ref $extraparams && ref $extraparams eq 'HASH'){
                    foreach my $key (keys %{$extraparams}){
                        next if $key eq 'dbh' && !$SESSION{'DBH_MASTER_AFTERPOST'};
                        next if $key eq 'rnd';
                        next if $key eq 'notifyid';
                        $url->query->remove($key);
                        $url->query->append($key => ${$extraparams}{$key}) if defined (${$extraparams}{$key});
                    }
                }
                
                $c->redirect_to($url);
                return;
            }
            return unless my $started = $c->stash('started');
            #session_store();
        }
    );

}

1;
