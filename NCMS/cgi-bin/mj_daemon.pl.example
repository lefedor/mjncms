#!/usr/bin/env perl -w

package MjNCMS;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#
# Todu coach: If there’s such as thing as natural talent,
# it just means that the person will improve just a little faster than everyone else.
# There's no such thing as an innate talent that overcomes repeated effort and practice.
# (c) initalD
#
# Professor: I can wire anything directly into anything - I'm the professor!
# (c) Futurama
#
	our $VERSION = '0.001-pre-alpha';

	use locale;
	use POSIX qw/locale_h /;
	use lib qw~./ ./lib~;

	$ENV{'MOJO_APP'} ||= 'MjNCMS';
	$ENV{'MOJO_HOME'} ||= File::Spec->catdir(split '/', $FindBin::Bin);
	$ENV{'MOJO_SERVER_DEBUG'} = 1;
	$ENV{'MOJO_RELOAD'} = 1;
	
	my %daemon_cfgs = (
		secret => 'oyaebu', 
		
	);
	
	use common::sense;
	use base 'Mojolicious';

	use File::Spec;
	use FindBin;
	
	use MjNCMS::Config qw/:vars /;
	use MjNCMS::Service qw/:subs /;

	#start once at script init
	sub startup {
		my $mojo = shift;
		
		$mojo = $mojo->secret($daemon_cfgs{'secret'});
		
		$mojo->log->level('debug');#0 to disable ???
		$mojo->log->path('./mj_log.log');
		#binmode STDERR, ':utf8';
		#$mojo->log->path(\*STDERR);
		
		$mojo->plugins->namespaces(['MjNCMS::Plugin', 'Mojolicious::Plugin']);
		#camelize will be used on plugin names, be ready for this:
			#use Mojo::ByteStream 'b';
			#print b('abc_def')->camelize; #output: 'AbcDef'
		$mojo->plugin('i18n');
		$mojo->plugin('mjncms_init');
		$mojo->plugin('mjncms_routes_extra');
		$mojo->plugin('mjncms_tt_renderer');
		
		my $r = $mojo->routes;
		#like 'ladder' @ Mojolicious::Lite
		#$r = $r->bridge->to(controller => 'Main', action => 'start_session');# vvv 

		my $adminroot = $SESSION{'ADM_URL'} || '/mjadmin';
		
		################################################################
		#							ADMIN SIDE
		################################################################
		#Controller is also chamelized, no ConTent, but con_tent, etc
		#Action used "as is"
		
		#Admin panel index
		my $adm_r = $r->route($adminroot);
		
		$adm_r->route('/')->via('get')->to(controller => 'Main', action => 'mjadmin_index_get');
		
		#Content Menus
		$adm_r->route('/menus')->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_get');
		$adm_r->route('/menus/add')->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_add_get');
		$adm_r->route('/menus/add/(:parent_menu_id)', {'parent_menu_id' => qr/\d+/})->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_add_get');
		$adm_r->route('/menus/add')->via('post')->
			to(controller => 'menus', action => 'menus_rt_menus_add_post');
		$adm_r->route('/menus/delete/(:rm_menu_id)', {'rm_menu_id' => qr/\d+/})->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_delete_get');
		$adm_r->route('/menus/delete')->via('post')->
			to(controller => 'menus', action => 'menus_rt_menus_delete_post');
		$adm_r->route('/menus/edit/(:menu_id)', {menu_id => qr/\d+/})->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_edit_get');
		$adm_r->route('/menus/edit')->via('post')->
			to(controller => 'menus', action => 'menus_rt_menus_edit_post');
		$adm_r->route('/menus/setsequence')->via('post')->
			to(controller => 'menus', action => 'menus_rt_menus_setsequence_post');
		$adm_r->route('/menus/managetrans/(:menu_id)', {menu_id => qr/\d+/})->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_managetrans_get');
		$adm_r->route('/menus/addtrans')->via('post')->
			to(controller => 'menus', action => 'menus_rt_menus_addtrans_post');
		$adm_r->route('/menus/updtrans')->via('post')->
			to(controller => 'menus', action => 'menus_rt_menus_updtrans_post');
		$adm_r->route('/menus/deltrans/(:menu_id)/(:menu_lang)' => {menu_id => qr/\d+/, menu_lang => qr/\w{2,4}/})->via('get')->
			to(controller => 'menus', action => 'menus_rt_menus_deltrans_get');
		
		#Content categories
		$adm_r->route('/content/cats')->via('get')->
			to(controller => 'content', action => 'content_rt_cats_get');
		$adm_r->route('/content/addcat')->via('get')->
			to(controller => 'content', action => 'content_rt_addcats_get');
		$adm_r->route('/content/addsubcat/(:parent_cat_id)', {parent_cat_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_addcats_get');
		$adm_r->route('/content/addsubcat')->via('post')->
			to(controller => 'content', action => 'content_rt_addcats_post');
		$adm_r->route('/content/catedit/(:cat_id)', {cat_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_editcats_get');
		$adm_r->route('/content/editcat')->via('post')->
			to(controller => 'content', action => 'content_rt_editcats_post');
		$adm_r->route('/content/catdelete/(:rm_cat_id)', {rm_cat_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_delcats_get');
		$adm_r->route('/content/setcatsequence')->via('post')->
			to(controller => 'content', action => 'content_rt_setcatsequence_post');
		$adm_r->route('/content/managecattrans/(:cat_id)', {cat_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_cats_managetrans_get');
		$adm_r->route('/content/addcattrans')->via('post')->
			to(controller => 'content', action => 'content_rt_cats_addtrans_post');
		$adm_r->route('/content/delcattrans/(:cat_id)/(:cat_lang)' => {cat_id => qr/\d+/, cat_lang => qr/\w{2,4}/})->via('get')->
			to(controller => 'content', action => 'content_rt_cats_deltrans_get');
		$adm_r->route('/content/updcattrans')->via('post')->
			to(controller => 'content', action => 'content_rt_cats_updtrans_post');		
		
		#Content pages
		$adm_r->route('/content/pages')->via('get')->
			to(controller => 'content', action => 'content_rt_pages_get');
		$adm_r->route('/content/addpage')->via('get')->
			to(controller => 'content', action => 'content_rt_addpages_get');
		$adm_r->route('/content/addpage')->via('post')->
			to(controller => 'content', action => 'content_rt_addpages_post');
		$adm_r->route('/content/editpage/(:page_id)', {page_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_editpages_get');
		$adm_r->route('/content/editpage/(:page_id)', {page_id => qr/\d+/})->via('post')->
			to(controller => 'content', action => 'content_rt_editpages_post');
		$adm_r->route('/content/delpage/(:page_id)', {page_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_deletepages_get');
		$adm_r->route('/content/page_managetrans/(:page_id)', {page_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_page_managetrans_get');
		$adm_r->route('/content/page_managetrans/(:page_id)/add', {page_id => qr/\d+/})->via('get')->
			to(controller => 'content', action => 'content_rt_page_managetrans_add_get');
		$adm_r->route('/content/page_managetrans/(:page_id)/save', {page_id => qr/\d+/})->via('post')->
			to(controller => 'content', action => 'content_rt_page_managetrans_save_post');
		$adm_r->route('/content/page_managetrans/(:page_id)/(:lang)/edit', {page_id => qr/\d+/, lang => qr/\w{2,4}/})->via('get')->
			to(controller => 'content', action => 'content_rt_page_managetrans_edit_get');
		$adm_r->route('/content/page_managetrans/(:page_id)/(:old_lang)/update', {page_id => qr/\d+/, old_lang => qr/\w{2,4}/})->via('post')->
			to(controller => 'content', action => 'content_rt_page_managetrans_update_post');
		$adm_r->route('/content/page_managetrans/(:page_id)/(:lang)/delete', {page_id => qr/\d+/, lang => qr/\w{2,4}/})->via('get')->
			to(controller => 'content', action => 'content_rt_page_managetrans_delete_get');
		
		#Content comments
		#next realise
		
		#Content tag clouds
		#next realise
		
		#"Subscribe" routes
		#next realise
		
		#Content short urls
		$adm_r->route('/content/short_urls')->via('get')->
			to(controller => 'content', action => 'content_rt_short_urls_get');
		$adm_r->route('/content/short_urls/add_grp')->via('get')->
			to(controller => 'content', action => 'content_rt_short_url_groups_add_get');
		$adm_r->route('/content/short_urls/add_grp')->via('post')->
			to(controller => 'content', action => 'content_rt_short_url_groups_add_post');
		$adm_r->route('/content/short_urls/edit_grp/(:sugrp_id)')->via('get')->
			to(controller => 'content', action => 'content_rt_short_url_groups_edit_get');
		$adm_r->route('/content/short_urls/edit_grp/(:sugrp_id)')->via('post')->
			to(controller => 'content', action => 'content_rt_short_url_groups_edit_post');
		$adm_r->route('/content/short_urls/delete_grp/(:sugrp_id)')->via('get')->
			to(controller => 'content', action => 'content_rt_short_url_groups_delete_get');
		$adm_r->route('/content/short_urls/add_url')->via('post')->
			to(controller => 'content', action => 'content_rt_short_urls_add_post');
		$adm_r->route('/content/short_urls/delete_url/(:alias_id)')->via('get')->
			to(controller => 'content', action => 'content_rt_short_urls_delete_get');
		
		#File management
		$adm_r->route('/content/filemanager')->via('get')->
			to(controller => 'content', action => 'content_filemanager_get');
		
		#Translations
		$adm_r->route('/translations')->via('get')->
			to(controller => 'translations', action => 'translations_rt_poollist_get');
		$adm_r->route('/translations/set_strings/(:lang)', {lang => qr/\w{2,4}/})->via('get')->
			to(controller => 'translations', action => 'translations_rt_set_strings_get');
		$adm_r->route('/translations/set_strings/(:lang)', {lang => qr/\w{2,4}/})->via('post')->
			to(controller => 'translations', action => 'translations_rt_set_strings_post');
		$adm_r->route('/translations/clear_cache/(:lang)', {lang => qr/\w{2,4}/})->via('get')->
			to(controller => 'translations', action => 'translations_rt_clear_cache_get');
			
		#System variables - store @db all settings from $$cfg except DB settings && write them over $$cfg @ init
		#next realise
		
		#Permissions
		$adm_r->route('/permissions')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_permissions_get');
		$adm_r->route('/permissions/add')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_permissions_add_get');
		$adm_r->route('/permissions/add')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_permissions_add_post');
		$adm_r->route('/permissions/edit/(:perm_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_permissions_edit_get');
		$adm_r->route('/permissions/edit/(:perm_id)')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_permissions_edit_post');
		$adm_r->route('/permissions/delete/(:perm_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_permissions_delete_get');
			
		#Automated workplaces / Roles management
		$adm_r->route('/awp_roles')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_get');
		$adm_r->route('/awp_roles/add_awp')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_add_awp_get');
		$adm_r->route('/awp_roles/add_awp')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_add_awp_post');
		$adm_r->route('/awp_roles/edit_awp/(:awp_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_edit_awp_get');
		$adm_r->route('/awp_roles/edit_awp/(:awp_id)')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_edit_awp_post');
		$adm_r->route('/awp_roles/delete_awp/(:awp_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_delete_awp_get');
		$adm_r->route('/awp_roles/setperm_awp/(:awp_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_setperm_awp_get');
		$adm_r->route('/awp_roles/setperm_awp/(:awp_id)')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_setperm_awp_post');
		$adm_r->route('/awp_roles/add_role')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_add_role_get');
		$adm_r->route('/awp_roles/add_role')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_add_role_post');
		$adm_r->route('/awp_roles/edit_role/(:role_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_edit_role_get');
		$adm_r->route('/awp_roles/edit_role/(:role_id)')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_edit_role_post');
		$adm_r->route('/awp_roles/delete_role/(:role_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_delete_role_get');
		$adm_r->route('/awp_roles/setperm_role/(:role_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_setperm_role_get');
		$adm_r->route('/awp_roles/setperm_role/(:role_id)')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_awproles_setperm_role_post');			
		
		#User Management
		$adm_r->route('/users')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_users_get');
		$adm_r->route('/users/add')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_users_add_get');
		$adm_r->route('/users/add')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_users_add_post');
		$adm_r->route('/users/edit/(:member_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_users_edit_get');
		$adm_r->route('/users/edit/(:member_id)')->via('post')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_users_edit_post');
		$adm_r->route('/users/delete/(:member_id)')->via('get')->
			to(controller => 'usercontroller', action => 'usercontroller_rt_users_delete_get');
	
		################################################################
		#							CONTENT SIDE
		################################################################
		#Index sealing, 
		$r->route('/')->via('get')->to(controller => 'content', action => 'content_rt_index_get');

		#Public file management
		$r->route('/content/filemanager_connector')->
			to(controller => 'content', action => 'content_rt_filemanager_connector_get');
		
		#Public content routes browse cats, view pages
		
		
		#Public user routes - login/logout/edit/reg/reg_confirm
		
	}	

	########################################################################
	#						RUN "THAT" :)
	########################################################################
	#like 'shagadelic' @ Mojolicious::Lite
	if (scalar @ARGV){
		#if command line params set
		Mojolicious->start(@ARGV);
	}
	else {
		#example of out-of-box start ready settings
		Mojolicious->start('fcgi_prefork', 
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

1;

package MjNCMS::Main;

	use common::sense;
	use base 'Mojolicious::Controller';

	use MjNCMS::Config qw/:vars /;
	use MjNCMS::Service qw/:subs /;

	#admin panel main page
	sub mjadmin_index_get () {
		my $self = shift;
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'}=$TT_VARS{'tt_controller'}='admin';
		$TT_CFG{'tt_action'}=$TT_VARS{'tt_action'}='index';
		$self->render('admin/admin_index');
	};
	
	#sub start_session (){ {
	#   #::Lite ladder example ^^^
	#	my $c = shift;#controller obj
	#}

1;

