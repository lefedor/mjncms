package MjNCMS::Usercontroller;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#
# Morbo: Hello little man. I WILL DESTROY YOU!
# (c) Futurama
#

use common::sense;
use base 'Mojolicious::Controller';

use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

########################################################################
#							ROUTE CALLS
########################################################################

sub usercontroller_rt_permissions_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('permissions', 'manage')) {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'permissions';
		$TT_CALLS{'permission_types_get'} = \&MjNCMS::Usercontroller::permission_types_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_permissions_get

sub usercontroller_rt_permissions_add_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('permissions', 'manage')) {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'permissions_add';
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_permissions_add_get

sub usercontroller_rt_permissions_add_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('permissions', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::permissions_mk_entry({
		controller => scalar $SESSION{'REQ'}->param('perm_controller'), 
		action => scalar $SESSION{'REQ'}->param('perm_action'), 
		descr => scalar $SESSION{'REQ'}->param('perm_descr'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/permissions' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			perm_id => $res->{'perm_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_permissions_add_post

sub usercontroller_rt_permissions_edit_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('permissions', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'permissions_edit';
		$TT_VARS{'perm_id'} = $self->param('perm_id');
		$TT_CALLS{'permission_types_get'} = \&MjNCMS::Usercontroller::permission_types_get;
	}
	$self->render('admin/admin_index');
	
} #-- usercontroller_rt_permissions_edit_get


sub usercontroller_rt_permissions_edit_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('permissions', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::permissions_edit_entry({
		perm_id => scalar $self->param('perm_id'), 
		controller => scalar $SESSION{'REQ'}->param('perm_controller'), 
		action => scalar $SESSION{'REQ'}->param('perm_action'), 
		descr => scalar $SESSION{'REQ'}->param('perm_descr'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/permissions' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			perm_id => $res->{'perm_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_permissions_edit_post

sub usercontroller_rt_permissions_delete_get () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('permissions', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::permissions_delete_entry({
		perm_id => scalar $self->param('perm_id'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/permissions' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			perm_id => $res->{'perm_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_permissions_delete_get

sub usercontroller_rt_awproles_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles';
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_get

sub usercontroller_rt_awproles_add_awp_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles_awp_add';
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_add_awp_get


sub usercontroller_rt_awproles_add_awp_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::awp_add_entry({
		name => scalar $SESSION{'REQ'}->param('awp_name'), 
		sequence => scalar $SESSION{'REQ'}->param('awp_seq'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/awp_roles' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			awp_id => $res->{'awp_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_add_awp_post

sub usercontroller_rt_awproles_edit_awp_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles_awp_edit';
		$TT_VARS{'awp_id'} = $self->param('awp_id');
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_edit_awp_get


sub usercontroller_rt_awproles_edit_awp_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::awp_edit_entry({
		awp_id => scalar $self->param('awp_id'), 
		name => scalar $SESSION{'REQ'}->param('awp_name'), 
		sequence => scalar $SESSION{'REQ'}->param('awp_seq'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/awp_roles' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			awp_id => $res->{'awp_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_edit_awp_post

sub usercontroller_rt_awproles_delete_awp_get () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::awp_delete_entry({
		awp_id => scalar $self->param('awp_id'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/permissions' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			awp_id => $res->{'awp_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_delete_awp_get

sub usercontroller_rt_awproles_add_role_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles_role_add';
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_add_role_get


sub usercontroller_rt_awproles_add_role_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::role_add_entry({
		awp_id => scalar $SESSION{'REQ'}->param('awp_id'), 
		name => scalar $SESSION{'REQ'}->param('role_name'), 
		sequence => scalar $SESSION{'REQ'}->param('role_seq'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/awp_roles' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			role_id => $res->{'role_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_add_role_post

sub usercontroller_rt_awproles_edit_role_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles_role_edit';
		$TT_VARS{'role_id'} = $self->param('role_id');
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_edit_role_get


sub usercontroller_rt_awproles_edit_role_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::role_edit_entry({
		role_id => scalar $self->param('role_id'), 
		awp_id => scalar $SESSION{'REQ'}->param('awp_id'), 
		name => scalar $SESSION{'REQ'}->param('role_name'), 
		sequence => scalar $SESSION{'REQ'}->param('role_seq'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/awp_roles' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			role_id => $res->{'role_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_edit_role_post

sub usercontroller_rt_awproles_delete_role_get () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::role_delete_entry({
		role_id => scalar $self->param('role_id'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/permissions' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			role_id => $res->{'role_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_delete_role_get

sub usercontroller_rt_awproles_setperm_awp_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles_setperm_awp';
		$TT_VARS{'awp_id'} = $self->param('awp_id');
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
		$TT_CALLS{'permission_types_get'} = \&MjNCMS::Usercontroller::permission_types_get;
		$TT_CALLS{'permissions_get'} = \&MjNCMS::Usercontroller::permissions_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_setperm_awp_get

sub usercontroller_rt_awproles_setperm_awp_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my %readables = &get_suffixed_params('awp_perm_r_');
	my %writables = &get_suffixed_params('awp_perm_w_');
	
	my $res = &MjNCMS::Usercontroller::setperm_awp({
		awp_id => scalar $self->param('awp_id'), 
		readables => [keys %readables], 
		writables => [keys %writables], 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/awp_roles' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			awp_id => $res->{'awp_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_setperm_awp_post

sub usercontroller_rt_awproles_setperm_role_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'awproles_setperm_role';
		$TT_VARS{'role_id'} = $self->param('role_id');
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
		$TT_CALLS{'permission_types_get'} = \&MjNCMS::Usercontroller::permission_types_get;
		$TT_CALLS{'permissions_get'} = \&MjNCMS::Usercontroller::permissions_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_awproles_setperm_role_get

sub usercontroller_rt_awproles_setperm_role_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my %readables = &get_suffixed_params('role_perm_r_');
	my %writables = &get_suffixed_params('role_perm_w_');
	
	my $res = &MjNCMS::Usercontroller::setperm_role({
		role_id => scalar $self->param('role_id'), 
		readables => [keys %readables], 
		writables => [keys %writables], 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/awp_roles' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			role_id => $res->{'role_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_awproles_setperm_role_post

sub usercontroller_rt_users_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('users', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'users';
		$TT_CALLS{'users_get'} = \&MjNCMS::Usercontroller::users_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_users_get

sub usercontroller_rt_users_add_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('users', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'users_add';
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
		$TT_CALLS{'users_get'} = \&MjNCMS::Usercontroller::users_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_users_add_get

sub usercontroller_rt_users_add_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('users', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my %extraslaves = &get_suffixed_params('repl_eusr_');
	
	my $res = &MjNCMS::Usercontroller::users_add({
		extraslaves => [keys %extraslaves], 
		login => scalar $SESSION{'REQ'}->param('usr_login'), 
		name => scalar $SESSION{'REQ'}->param('usr_name'), 
		password => scalar $SESSION{'REQ'}->param('usr_pass'), 
		password_retype => scalar $SESSION{'REQ'}->param('usr_pass_retype'), 
		roles => [$SESSION{'REQ'}->param('role_id')], 
		startpage => scalar $SESSION{'REQ'}->param('usr_startpage'), 
		email => scalar $SESSION{'REQ'}->param('usr_email'), 
		lang => scalar $SESSION{'REQ'}->param('usr_lang'), 
		is_cms_active => scalar $SESSION{'REQ'}->param('usr_isac'), 
		is_forum_active => scalar $SESSION{'REQ'}->param('usr_isa'), 
		
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/users' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			role_id => $res->{'role_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_users_add_post

sub usercontroller_rt_users_edit_get () {
	my $self = shift;

	unless ($SESSION{'USR'}->chk_access('users', 'manage')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
	}
	else {
		$SESSION{'PAGE_CACHABLE'} = 1;
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'users_edit';
		$TT_VARS{'member_id'} = $self->param('member_id');
		$TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
		$TT_CALLS{'users_get'} = \&MjNCMS::Usercontroller::users_get;
	}
	$self->render('admin/admin_index');

} #-- usercontroller_rt_users_edit_get

sub usercontroller_rt_users_edit_post () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('users', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my %extraslaves = &get_suffixed_params('repl_eusr_');
	
	my $res = &MjNCMS::Usercontroller::users_edit({
		member_id => scalar $self->param('member_id'), 
		extraslaves => [keys %extraslaves], 
		name => scalar $SESSION{'REQ'}->param('usr_name'), 
		password => scalar $SESSION{'REQ'}->param('usr_pass'), 
		password_retype => scalar $SESSION{'REQ'}->param('usr_pass_retype'), 
		roles => [$SESSION{'REQ'}->param('role_id')], 
		startpage => scalar $SESSION{'REQ'}->param('usr_startpage'), 
		email => scalar $SESSION{'REQ'}->param('usr_email'), 
		lang => scalar $SESSION{'REQ'}->param('usr_lang'), 
		is_cms_active => scalar $SESSION{'REQ'}->param('usr_isac'), 
		is_forum_active => scalar $SESSION{'REQ'}->param('usr_isa'), 
		
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/users' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			role_id => $res->{'role_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_users_edit_post

sub usercontroller_rt_users_delete_get () {
	my $self = shift;
	
	unless ($SESSION{'USR'}->chk_access('users', 'manage', 'w')) {
		$TT_CFG{'tt_controller'} = 
			$TT_VARS{'tt_controller'} = 
				'admin';
		$TT_CFG{'tt_action'} = 
			$TT_VARS{'tt_action'} = 
				'no_access_perm';
		$self->render('admin/admin_index');
		return;
	}
	
	my $res = &MjNCMS::Usercontroller::users_delete({
		member_id => scalar $self->param('member_id'), 
	});
	
	my $url;
	unless ($SESSION{'REQ_ISAJAX'}) {
		if ($SESSION{'REFERER'}) {
			$url = $SESSION{'REFERER'};
		}
		elsif ($SESSION{'HTTP_REFERER'}) {
			$url = $SESSION{'HTTP_REFERER'};
		}
		$url = $SESSION{'ADM_URL'}.'/users' unless $url;
		$SESSION{'REDIR'} = {
			url => $url, 
			msg => $res->{'message'}, 
		};
		return;
	}
	else {
		$self->render_json({
			status => $res->{'status'}, 
			message => $SESSION{'LOC'}->loc($res->{'message'}), 
			member_id => $res->{'member_id'}, 
			
		});
	}
	
} #-- usercontroller_rt_users_delete_get

########################################################################
#							INTERNAL SUBS
########################################################################

sub permission_types_get (;$) {
	my $cfg = shift;
	
	$cfg = {} unless $cfg;
	
	my (
		$dbh, 
		$q, $res, $sth, $where_rule, 
		@permissions, %permissions, 
		
	) = ($SESSION{'DBH'}, );
	
	$where_rule = '';
	if (${$cfg}{'perm_id'} && !(ref ${$cfg}{'perm_id'}) && ${$cfg}{'perm_id'} =~ /^\d+$/) {
		$where_rule .= ' AND pt.permission_id = ' . ($dbh -> quote (${$cfg}{'perm_id'})) . ' ';
	}
	
	if (${$cfg}{'perm_ids'} && 
		ref ${$cfg}{'perm_ids'} && 
			${$cfg}{'perm_ids'} eq 'ARRAY' && 
				scalar @{${$cfg}{'perm_ids'}} && 
					!(scalar (grep(/\D/, @{${$cfg}{'perm_ids'}})))) {
						$where_rule .= ' AND pt.permission_id IN ' . (join ', ', @{${$cfg}{'perm_ids'}}) . ' ';
	}
	
	$where_rule =~ s/AND/WHERE/;
	
	$q = qq~ 
		SELECT 
			pt.permission_id, pt.member_id, 
			pt.controller, pt.action, pt.descr 
		FROM ${SESSION{PREFIX}}permission_types pt 
		$where_rule
		ORDER BY pt.controller ASC, pt.action ASC ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute();
		unless (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash') {
			while ($res = $sth->fetchrow_hashref()) {
				$res->{'is_writable'} = 1 if 
					$SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
				push @permissions, {%{$res}};
			}
		}
		else {
			while ($res = $sth->fetchrow_hashref()) {
				$res->{'is_writable'} = 1 if 
					$SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
				$permissions{ $res -> {'permission_id'} } = {%{$res}};
			}
		}
		$sth -> finish();
	};
	
	return {
		q => $q, 
		permissions => (${$cfg}{'mode'} eq 'as_hash')? \%permissions:\@permissions,
	}
} #-- permission_types_get

sub permissions_get ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
	
	my (
		$dbh, 
		$q, $res, $sth, $where_rule, 
		@perms, %perms
	) = ($SESSION{'DBH'}, );
	
	$where_rule = '';
	if (${$cfg}{'role_id'} && !(ref ${$cfg}{'role_id'}) && ${$cfg}{'role_id'} =~ /^\d+$/) {
		$where_rule .= ' WHERE p.role_id = ' . ($dbh -> quote (${$cfg}{'role_id'})) . ' ';
	}
	elsif (${$cfg}{'awp_id'} && !(ref ${$cfg}{'awp_id'}) && ${$cfg}{'awp_id'} =~ /^\d+$/) {
		$where_rule .= ' WHERE p.awp_id = ' . ($dbh -> quote (${$cfg}{'awp_id'})) . ' ';
	}
	else {
		return {
				status => 'fail', 
				message => 'no awp_id/role_id queryed', 
		}
	}
	
	$q = qq~
		SELECT 
			pt.permission_id, 
			pt.controller, pt.action, p.r, p.w 
		FROM ${SESSION{PREFIX}}permissions p 
			LEFT JOIN ${SESSION{PREFIX}}permission_types pt 
				ON pt.permission_id=p.permission_id
		$where_rule
		ORDER BY pt.controller ASC, pt.action ASC ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute();
		unless (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'array') {
			while ($res = $sth->fetchrow_hashref()) {
				$perms{$res->{'permission_id'}} = {%{$res}};
			}
		}
		else {
			while ($res = $sth->fetchrow_hashref()) {
				push @perms, {%{$res}};
			}
		}
		$sth -> finish();
	};
	
	return {
		q => $q, 
		perms => (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'array')? \@perms:\%perms, 
	}
	
} #-- permissions_get

sub permissions_mk_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with permissions', 
	} unless (
		$SESSION{'USR'}->chk_access('permissions', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'controller len fail',
	} if (
		!defined(${$cfg}{'controller'}) ||
		${$cfg}{'controller'} !~ /^.{1,32}$/
	); 
	
	return {
		status => 'fail', 
		message => 'action len fail',
	} if (
		!defined(${$cfg}{'action'}) ||
		${$cfg}{'action'} !~ /^.{1,32}$/
	); 
	
	return {
		status => 'fail', 
		message => 'descr len fail',
	} if (
		${$cfg}{'descr'} &&
		${$cfg}{'descr'} !~ /^.{1,64}$/
	); 
	
	${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
	
	my (
		$dbh, $q, 
		$inscnt, $perm_id, 
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		INSERT INTO 
		${SESSION{PREFIX}}permission_types (
			controller, action, descr, 
			member_id, ins 
		) VALUES (
			~ . ($dbh->quote(${$cfg}{'controller'})) . qq~, 
			~ . ($dbh->quote(${$cfg}{'action'})) . qq~, 
			~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
			~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
			NOW() 
		) ; 
	~;
	eval {
		$inscnt = $dbh->do($q);
	};

	unless (scalar $inscnt) {
		return {
			status => 'fail', 
			message => 'sql ins into permission_types entry fail', 
		}
	}

	$q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
	eval {
		($perm_id) = $dbh -> selectrow_array($q);
	};

	return {
		status => 'ok', 
		perm_id => $perm_id, 
		message => 'All ok', 
	};
	
} #-- permissions_mk_entry

sub permissions_edit_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with permissions', 
	} unless (
		$SESSION{'USR'}->chk_access('permissions', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'perm_id incorrect', 
	} unless ${$cfg}{'perm_id'} =~ /^\d+$/;

	return {
		status => 'fail', 
		message => 'controller len fail',
	} if (
		!defined(${$cfg}{'controller'}) ||
		${$cfg}{'controller'} !~ /^.{1,32}$/
	); 
	
	return {
		status => 'fail', 
		message => 'action len fail',
	} if (
		!defined(${$cfg}{'action'}) ||
		${$cfg}{'action'} !~ /^.{1,32}$/
	); 
	
	return {
		status => 'fail', 
		message => 'descr len fail',
	} if (
		${$cfg}{'descr'} &&
		${$cfg}{'descr'} !~ /^.{1,64}$/
	); 
	
	${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
	
	my (
		$dbh, $sth, $res, $q, 
		$updcnt
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT pt.permission_id, pt.member_id 
		FROM ${SESSION{PREFIX}}permission_types pt
		WHERE pt.permission_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'perm_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'perm not exist', 
	} unless scalar $res -> {'permission_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'perm out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		UPDATE 
		${SESSION{PREFIX}}permission_types 
		SET 
			controller = ~ . ($dbh->quote(${$cfg}{'controller'})) . qq~, 
			action = ~ . ($dbh->quote(${$cfg}{'action'})) . qq~, 
			descr = ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
			whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~ 
		WHERE permission_id = ~ . ($dbh->quote(${$cfg}{'perm_id'})) . qq~ ;
	~;
	eval {
		$updcnt = $dbh->do($q);
	};

	unless (scalar $updcnt) {
		return {
			status => 'fail', 
			message => 'sql upd into permission_types entry fail', 
		}
	}

	return {
		status => 'ok', 
		perm_id => ${$cfg}{'perm_id'}, 
		message => 'All ok', 
	};
	
} #-- permissions_edit_entry

sub permissions_delete_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with permissions', 
	} unless (
		$SESSION{'USR'}->chk_access('permissions', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'perm_id incorrect', 
	} unless ${$cfg}{'perm_id'} =~ /^\d+$/;

	my (
		$dbh, $sth, $res, $q, 
		$delcnt
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT pt.permission_id, pt.member_id 
		FROM ${SESSION{PREFIX}}permission_types pt
		WHERE pt.permission_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'perm_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'perm not exist', 
	} unless scalar $res -> {'permission_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'perm out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}permission_types 
		WHERE permission_id = ~ . ($dbh->quote(${$cfg}{'perm_id'})) . qq~ ;
	~;
	eval {
		$delcnt = $dbh->do($q);
	};

	unless (scalar $delcnt) {
		return {
			status => 'fail', 
			message => 'sql delete onto permission_types entry fail', 
		}
	}

	return {
		status => 'ok', 
		perm_id => ${$cfg}{'perm_id'}, 
		message => 'All ok', 
	};
	
} #-- permissions_delete_entry

sub awproles_get (;$) {
	my $cfg = shift;
	$cfg = {} unless $cfg;
	
	my (
		$dbh, 
		$qr, $qa, $res, $sth, 
		$where_rule, 
		@awps_seq_list, %awps, 
		%roles_seq_list, %roles, 
		
	) = ($SESSION{'DBH'}, );
	
	$where_rule = '';
	if (${$cfg}{'role_id'} && !(ref ${$cfg}{'role_id'}) && ${$cfg}{'role_id'} =~ /^\d+$/) {
		$where_rule .= ' AND r.role_id = ' . ($dbh -> quote (${$cfg}{'role_id'})) . ' ';
	}
	
	if (${$cfg}{'role_ids'} && 
		ref ${$cfg}{'role_ids'} && 
			${$cfg}{'role_ids'} eq 'ARRAY' && 
				scalar @{${$cfg}{'role_ids'}} && 
					!(scalar (grep(/\D/, @{${$cfg}{'role_ids'}})))) {
						$where_rule .= ' AND r.role_id IN ' . (join ', ', @{${$cfg}{'role_ids'}}) . ' ';
	}
	
	if (${$cfg}{'awp_id'} && !(ref ${$cfg}{'awp_id'}) && ${$cfg}{'awp_id'} =~ /^\d+$/) {
		$where_rule .= ' AND r.awp_id = ' . ($dbh -> quote (${$cfg}{'awp_id'})) . ' ';
	}
	
	if (${$cfg}{'awp_ids'} && 
		ref ${$cfg}{'awp_ids'} && 
			${$cfg}{'awp_ids'} eq 'ARRAY' && 
				scalar @{${$cfg}{'awp_ids'}} && 
					!(scalar (grep(/\D/, @{${$cfg}{'awp_ids'}})))) {
						$where_rule .= ' AND r.awp_id IN ' . (join ', ', @{${$cfg}{'awp_ids'}}) . ' ';
	}
	
	$where_rule =~ s/AND/WHERE/;
	
	$qr = qq~ 
		SELECT 
			r.role_id, r.awp_id, r.name, 
			r.member_id, r.sequence 
		FROM ${SESSION{PREFIX}}roles r 
		$where_rule 
		ORDER BY r.awp_id ASC, r.sequence ASC ; 
	~;
	eval {
		$sth = $dbh -> prepare($qr); $sth -> execute();
			while ($res = $sth->fetchrow_hashref()) {
				$res->{'is_writable'} = 1 if 
					$SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
				$roles_seq_list{$res->{'awp_id'}} = [] unless $roles_seq_list{$res->{'awp_id'}};
				push @{$roles_seq_list{$res->{'awp_id'}}}, $res->{'role_id'};
				$roles{$res->{'role_id'}} = {%{$res}};
			}
		$sth -> finish();
	};

	if (${$cfg}{'role_id'} || ${$cfg}{'role_ids'}) {
		${$cfg}{'awp_ids'}  = [] unless ${$cfg}{'awp_ids'} && ref ${$cfg}{'awp_ids'};
		push @{${$cfg}{'awp_ids'}}, keys %roles_seq_list;
	}

	$where_rule = '';
	if (${$cfg}{'awp_id'} && !(ref ${$cfg}{'awp_id'}) && ${$cfg}{'awp_id'} =~ /^\d+$/) {
		$where_rule .= ' AND a.awp_id = ' . ($dbh -> quote (${$cfg}{'awp_id'})) . ' ';
	}
	
	if (${$cfg}{'awp_ids'} && 
		ref ${$cfg}{'awp_ids'} && 
			${$cfg}{'awp_ids'} eq 'ARRAY' && 
				scalar @{${$cfg}{'awp_ids'}} && 
					!(scalar (grep(/\D/, @{${$cfg}{'awp_ids'}})))) {
						$where_rule .= ' AND a.awp_id IN ' . (join ', ', @{${$cfg}{'awp_ids'}}) . ' ';
	}
	
	$where_rule =~ s/AND/WHERE/;
	
	$qa = qq~ 
		SELECT 
			a.awp_id, a.name, 
			a.member_id, a.sequence 
		FROM ${SESSION{PREFIX}}awps a 
		$where_rule 
		ORDER BY a.sequence ASC ; 
	~;
	eval {
		$sth = $dbh -> prepare($qa); $sth -> execute();
			while ($res = $sth->fetchrow_hashref()) {
				$res->{'is_writable'} = 1 if 
					$SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
				push @awps_seq_list, $res->{'awp_id'};
				$awps{$res->{'awp_id'}} = {%{$res}};
			}
		$sth -> finish();
	};

	return {
		qr => $qr, 
		qa => $qa,
		awps_seq_list => \@awps_seq_list, 
		awps => \%awps, 
		roles_seq_list => \%roles_seq_list, 
		roles => \%roles, 
		
	}
} #-- awproles_get

sub awp_add_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'name len fail',
	} if (
		!defined(${$cfg}{'name'}) ||
		${$cfg}{'name'} !~ /^.{1,48}$/
	); 
	
	return {
		status => 'fail', 
		message => 'sequence chk fail',
	} if (
		!defined(${$cfg}{'sequence'}) ||
		${$cfg}{'sequence'} !~ /^\d{1,3}$/ ||
		(scalar ${$cfg}{'sequence'}) > 255
	); 
	
	my (
		$dbh, $sth, $res, $q, 
		$inscnt, $awp_id, 
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		INSERT INTO 
		${SESSION{PREFIX}}awps (
			name, sequence, 
			member_id, ins 
		) VALUES (
			~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
			~ . ($dbh->quote(${$cfg}{'sequence'})) . qq~, 
			~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
			NOW() 
		) ; 
	~;
	eval {
		$inscnt = $dbh->do($q);
	};

	unless (scalar $inscnt) {
		return {
			status => 'fail', 
			message => 'sql ins into awps fail', 
		}
	}

	$q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
	eval {
		($awp_id) = $dbh -> selectrow_array($q);
	};

	return {
		status => 'ok', 
		awp_id => $awp_id, 
		message => 'All ok', 
	};
} #-- awp_add_entry

sub awp_edit_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'awp_id chk fail',
	} if (
		!defined(${$cfg}{'awp_id'}) ||
		${$cfg}{'awp_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'name len fail',
	} if (
		!defined(${$cfg}{'name'}) ||
		${$cfg}{'name'} !~ /^.{1,48}$/
	); 
	
	return {
		status => 'fail', 
		message => 'sequence chk fail',
	} if (
		!defined(${$cfg}{'sequence'}) ||
		${$cfg}{'sequence'} !~ /^\d{1,3}$/ ||
		(scalar ${$cfg}{'sequence'}) > 255
	); 
	
	my (
		$dbh, $sth, $res, $q, 
		$updcnt
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT a.awp_id, a.member_id 
		FROM ${SESSION{PREFIX}}awps a
		WHERE a.awp_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'awp_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'awp not exist', 
	} unless scalar $res -> {'awp_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'awp out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		UPDATE ${SESSION{PREFIX}}awps 
		SET 
			name = ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
			sequence = ~ . ($dbh->quote(${$cfg}{'sequence'})) . qq~, 
			whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~ 
		WHERE awp_id = ~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~ ; 
	~;
	eval {
		$updcnt = $dbh->do($q);
	};

	unless (scalar $updcnt) {
		return {
			status => 'fail', 
			message => 'sql upd on awps fail', 
		}
	}

	return {
		status => 'ok', 
		awp_id => ${$cfg}{'awp_id'}, 
		message => 'All ok', 
	};
} #-- awp_edit_entry

sub awp_delete_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'awp_id chk fail',
	} if (
		!defined(${$cfg}{'awp_id'}) ||
		${$cfg}{'awp_id'} !~ /^\d+$/ 
	); 
	
	my (
		$dbh, $sth, $res, $q, 
		$delcnt
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT a.awp_id, a.member_id 
		FROM ${SESSION{PREFIX}}awps a
		WHERE a.awp_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'awp_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'awp not exist', 
	} unless scalar $res -> {'awp_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'awp out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}roles 
		WHERE awp_id = ~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~ ; 
	~;
	eval { $dbh->do($q); };
		
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}awps 
		WHERE awp_id = ~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~ ; 
	~;
	eval {
		$delcnt = $dbh->do($q);
	};

	unless (scalar $delcnt) {
		return {
			status => 'fail', 
			message => 'sql del in awps fail', 
		}
	}

	return {
		status => 'ok', 
		awp_id => ${$cfg}{'awp_id'}, 
		message => 'All ok', 
	};
} #-- awp_delete_entry

sub role_add_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'awp_id chk fail',
	} if (
		!defined(${$cfg}{'awp_id'}) ||
		${$cfg}{'awp_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'name len fail',
	} if (
		!defined(${$cfg}{'name'}) ||
		${$cfg}{'name'} !~ /^.{1,48}$/
	); 
	
	return {
		status => 'fail', 
		message => 'sequence chk fail',
	} if (
		!defined(${$cfg}{'sequence'}) ||
		${$cfg}{'sequence'} !~ /^\d{1,3}$/ ||
		(scalar ${$cfg}{'sequence'}) > 255
	); 
	
	my (
		$dbh, $sth, $res, $q, 
		$inscnt, $role_id, 
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT a.awp_id, a.member_id 
		FROM ${SESSION{PREFIX}}awps a
		WHERE a.awp_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'awp_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'awp not exist', 
	} unless scalar $res -> {'awp_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'awp out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		INSERT INTO 
		${SESSION{PREFIX}}roles (
			awp_id, name, sequence, 
			member_id, ins 
		) VALUES (
			~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~, 
			~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
			~ . ($dbh->quote(${$cfg}{'sequence'})) . qq~, 
			~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
			NOW() 
		) ; 
	~;
	eval {
		$inscnt = $dbh->do($q);
	};

	unless (scalar $inscnt) {
		return {
			status => 'fail', 
			message => 'sql ins into awps fail', 
		}
	}

	$q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
	eval {
		($role_id) = $dbh -> selectrow_array($q);
	};

	return {
		status => 'ok', 
		role_id => $role_id, 
		message => 'All ok', 
	};
} #-- role_add_entry

sub role_edit_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'role_id chk fail',
	} if (
		!defined(${$cfg}{'role_id'}) ||
		${$cfg}{'role_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'awp_id chk fail',
	} if (
		!defined(${$cfg}{'awp_id'}) ||
		${$cfg}{'awp_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'name len fail',
	} if (
		!defined(${$cfg}{'name'}) ||
		${$cfg}{'name'} !~ /^.{1,48}$/
	); 
	
	return {
		status => 'fail', 
		message => 'sequence chk fail',
	} if (
		!defined(${$cfg}{'sequence'}) ||
		${$cfg}{'sequence'} !~ /^\d{1,3}$/ ||
		(scalar ${$cfg}{'sequence'}) > 255
	); 
	
	my (
		$dbh, $sth, $res, $q, 
		$updcnt
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT r.role_id, r.member_id 
		FROM ${SESSION{PREFIX}}roles r
		WHERE r.role_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'role_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'role not exist', 
	} unless scalar $res -> {'role_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'role out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		SELECT a.awp_id, a.member_id 
		FROM ${SESSION{PREFIX}}awps a
		WHERE a.awp_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'awp_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'awp not exist', 
	} unless scalar $res -> {'awp_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'awp out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		UPDATE ${SESSION{PREFIX}}roles 
		SET 
			awp_id = ~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~, 
			name = ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
			sequence = ~ . ($dbh->quote(${$cfg}{'sequence'})) . qq~, 
			whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~ 
		WHERE role_id = ~ . ($dbh->quote(${$cfg}{'role_id'})) . qq~ ; 
	~;
	eval {
		$updcnt = $dbh->do($q);
	};

	unless (scalar $updcnt) {
		return {
			status => 'fail', 
			message => 'sql upd on roles fail', 
		}
	}

	return {
		status => 'ok', 
		role_id => ${$cfg}{'role_id'}, 
		message => 'All ok', 
	};
} #-- role_edit_entry

sub role_delete_entry ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'role_id chk fail',
	} if (
		!defined(${$cfg}{'role_id'}) ||
		${$cfg}{'role_id'} !~ /^\d+$/ 
	); 
	
	my (
		$dbh, $sth, $res, $q, 
		$delcnt
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT r.role_id, r.member_id 
		FROM ${SESSION{PREFIX}}roles r
		WHERE r.role_id = ? ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'role_id'});
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'role not exist', 
	} unless scalar $res -> {'role_id'};
	
	#Anyone who have access to manage controller can use this func
	#return {
	#	status => 'fail', 
	#	message => 'role out of permissions', 
	#} unless $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} );
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}roles 
		WHERE role_id = ~ . ($dbh->quote(${$cfg}{'role_id'})) . qq~ ; 
	~;
	eval {
		$delcnt = $dbh->do($q);
	};

	unless (scalar $delcnt) {
		return {
			status => 'fail', 
			message => 'sql del in roles fail', 
		}
	}

	return {
		status => 'ok', 
		role_id => ${$cfg}{'role_id'}, 
		message => 'All ok', 
	};
} #-- role_delete_entry

sub setperm_awp ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'awp_id chk fail',
	} if (
		!defined(${$cfg}{'awp_id'}) ||
		${$cfg}{'awp_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'readables chk fail',
	} if (
		!defined(${$cfg}{'readables'}) ||
		!(ref ${$cfg}{'readables'}) || 
		!(ref ${$cfg}{'readables'} eq 'ARRAY')
	); 
	
	return {
		status => 'fail', 
		message => 'writables chk fail',
	} if (
		!defined(${$cfg}{'writables'}) ||
		!(ref ${$cfg}{'writables'}) || 
		!(ref ${$cfg}{'writables'} eq 'ARRAY')
	); 

	my (
		$dbh, $sth, $res, $q, 
		%perm_sets, @qs, $inscnt 
	) = ($SESSION{'DBH'}, );
	
	foreach my $r (@{${$cfg}{'readables'}}){
		$perm_sets{$r} = {} unless $perm_sets{$r};
		${$perm_sets{$r}}{'is_r'} = 1;
	}
	
	foreach my $w (@{${$cfg}{'writables'}}){
		$perm_sets{$w} = {} unless $perm_sets{$w};
		${$perm_sets{$w}}{'is_w'} = 1;
	}
	
	foreach my $permission_id (keys %perm_sets){
		push @qs,
			qq~ (~ . ($dbh->quote($permission_id)) . qq~, 
			~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~, 
			~ . ((defined(${$perm_sets{$permission_id}}{'is_r'}))? 1:0) . qq~, 
			~ . ((defined(${$perm_sets{$permission_id}}{'is_w'}))? 1:0) . qq~, 
			~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
			NOW() ) ~;
	}

	$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}permissions WRITE, ${SESSION{PREFIX}}roles READ ; ");
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}permissions 
		WHERE awp_id = ~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~ ; 
	~;
	eval {
		$dbh->do($q);
	};

	if (scalar @qs){
		#if permission defined @AWP, remove same sets from slave roles
		$q = qq~
			DELETE 
			FROM ${SESSION{PREFIX}}permissions 
			WHERE role_id IN (
				SELECT role_id 
				FROM ${SESSION{PREFIX}}roles 
				WHERE awp_id = ~ . ($dbh->quote(${$cfg}{'awp_id'})) . qq~ 
			) AND permission_id IN ( ~ . (join ', ', keys %perm_sets) . qq~ ); 
		~;
		eval {
			$dbh->do($q);
		};
		
		$q = qq~
			INSERT INTO 
			${SESSION{PREFIX}}permissions (
				permission_id, awp_id, r, w, 
				member_id, ins
			) VALUES ~ . (join ', ', @qs) . qq~  ; 
		~;
		eval {
			$inscnt = $dbh->do($q);
		};
		
		unless (
			(scalar $inscnt) == (scalar @qs)
		){
			$dbh -> do("UNLOCK TABLES ; ");
			return {
				status => 'fail', 
				message => 'real inserted count does not match expected count. AWP\'s sets could be inserted not completley', 
			}
		}
	}
	
	$dbh -> do("UNLOCK TABLES ; ");
	
	return {
		status => 'ok', 
		awp_id => ${$cfg}{'awp_id'}, 
		message => 'All ok', 
	};
} #-- setperm_awp

sub setperm_role ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with awp/roles', 
	} unless (
		$SESSION{'USR'}->chk_access('awp_roles', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'role_id chk fail',
	} if (
		!defined(${$cfg}{'role_id'}) ||
		${$cfg}{'role_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'readables chk fail',
	} if (
		!defined(${$cfg}{'readables'}) ||
		!(ref ${$cfg}{'readables'}) || 
		!(ref ${$cfg}{'readables'} eq 'ARRAY')
	); 
	
	return {
		status => 'fail', 
		message => 'writables chk fail',
	} if (
		!defined(${$cfg}{'writables'}) ||
		!(ref ${$cfg}{'writables'}) || 
		!(ref ${$cfg}{'writables'} eq 'ARRAY')
	); 

	my (
		$dbh, $sth, $res, $q, 
		%perm_sets, @qs, $inscnt 
	) = ($SESSION{'DBH'}, );
	
	foreach my $r (@{${$cfg}{'readables'}}){
		$perm_sets{$r} = {} unless $perm_sets{$r};
		${$perm_sets{$r}}{'is_r'} = 1;
	}
	
	foreach my $w (@{${$cfg}{'writables'}}){
		$perm_sets{$w} = {} unless $perm_sets{$w};
		${$perm_sets{$w}}{'is_w'} = 1;
	}
	
	foreach my $permission_id (keys %perm_sets){
		push @qs,
			qq~ (~ . ($dbh->quote($permission_id)) . qq~, 
			~ . ($dbh->quote(${$cfg}{'role_id'})) . qq~, 
			~ . ((defined(${$perm_sets{$permission_id}}{'is_r'}))? 1:0) . qq~, 
			~ . ((defined(${$perm_sets{$permission_id}}{'is_w'}))? 1:0) . qq~, 
			~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
			NOW() ) ~;
	}

	$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}permissions WRITE ; ");
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}permissions 
		WHERE role_id = ~ . ($dbh->quote(${$cfg}{'role_id'})) . qq~ ; 
	~;
	eval {
		$dbh->do($q);
	};
	
	if (scalar @qs){
		$q = qq~
			INSERT INTO 
			${SESSION{PREFIX}}permissions (
				permission_id, role_id, r, w, 
				member_id, ins
			) VALUES ~ . (join ', ', @qs) . qq~  ; 
		~;
		eval {
			$inscnt = $dbh->do($q);
		};
		
		unless (
			(scalar $inscnt) == (scalar @qs)
		){
			$dbh -> do("UNLOCK TABLES ; ");
			return {
				status => 'fail', 
				message => 'real inserted count does not match expected count. Role sets could be inserted not completley', 
			}
		}
	}
	
	$dbh -> do("UNLOCK TABLES ; ");
	
	return {
		status => 'ok', 
		role_id => ${$cfg}{'role_id'}, 
		message => 'All ok', 
	};
} #-- setperm_role

sub users_get ($) {
	my $cfg = shift;
	$cfg = {} unless $cfg;

	return $SESSION{'USR'}->users_get($cfg);
} #-- users_get

sub users_add ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with users', 
	} unless (
		$SESSION{'USR'}->chk_access('users', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'login len fail',
	} unless (
		defined ${$cfg}{'login'} && 
		length ${$cfg}{'login'}
	); 
	
	return {
		status => 'fail', 
		message => 'passwd chk fail',
	} unless (
		${$cfg}{'password'} &&
		length ${$cfg}{'password'} &&
		${$cfg}{'password'} eq ${$cfg}{'password_retype'}
	);

	return {
		status => 'fail', 
		message => 'name len fail',
	} unless (
		defined ${$cfg}{'name'} && 
		length ${$cfg}{'name'}
	); 

	return {
		status => 'fail', 
		message => 'roles chk fail',
	} if (
		!defined(${$cfg}{'roles'}) || 
		!(ref ${$cfg}{'roles'}) || 
		!(ref ${$cfg}{'roles'} eq 'ARRAY') || 
		!(scalar @{${$cfg}{'roles'}})  || 
		scalar (grep(/\D/, @{${$cfg}{'roles'}}))
	); 

	if (
		${$cfg}{'lang'} && ${$cfg}{'lang'} ne 'no_lang'		
	){
		return {
			status => 'fail', 
			message => 'lang unknown', 
		} if (
			!&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
		); 
	}
	else {
		${$cfg}{'lang'} = undef;
	}

	${$cfg}{'is_cms_active'} = ${$cfg}{'is_cms_active'}? 1:0;
	${$cfg}{'is_forum_active'} = ${$cfg}{'is_forum_active'}? 1:0;
	
	my (
		$dbh, $sth, 
		$res, $q, @qs, @slave_users, 
		$inscnt, $member_id, $role_id, 
		
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT  
		r.awp_id, r.role_id, 
		a.sequence AS awp_sequence, 
		r.sequence AS role_sequence 
		FROM ${SESSION{PREFIX}}roles r 
			LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
		WHERE r.role_id IN (~ . (join ', ', @{${$cfg}{'roles'}}) . qq~)
		ORDER BY a.sequence DESC, r.sequence DESC 
		LIMIT 0, 1 ; 
	~;
	
	eval{
		$sth = $dbh -> prepare($q); $sth -> execute();
		$res = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'new role is not found', 
	} unless defined($res -> {'role_id'});
	
	$role_id = $res -> {'role_id'};
	
	$member_id = $SESSION{'USR'}->register_hs({
		login => ${$cfg}{'login'}, 
		password => ${$cfg}{'password'}, 
		email => ${$cfg}{'email'}, 
		name => ${$cfg}{'name'}, 
		role_id => $role_id, 
		is_cms_active => ${$cfg}{'is_cms_active'}, 
		is_forum_active => ${$cfg}{'is_forum_active'}, 
		lang => ${$cfg}{'lang'}, 
		startpage => ${$cfg}{'startpage'}, 
	});
	
	unless (
		$member_id && 
		ref $member_id &&
		ref $member_id eq 'HASH' && 
		${$member_id}{'member_id'} =~ /^\d+$/
	) {
		return {
			status => 'fail', 
			message => 'user is not created: ' . $SESSION{'USR'}->{'last_state'}, 
		}
	}
	else {
		$member_id = ${$member_id}{'member_id'};
	}
	
	@qs = ();
	if (scalar @{${$cfg}{'roles'}} > 1) {
		foreach my $role_id (@{${$cfg}{'roles'}}) {
			push @qs , q~ (~ . ($dbh->quote($member_id)) . q~, ~ . 
			($dbh->quote($role_id)) . q~, ~ . 
			($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . q~) ~;
		}
	}
	
	if (scalar @qs){
		
		$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}role_alternatives WRITE ; ");
		
		$q = qq~
			INSERT INTO 
			${SESSION{PREFIX}}role_alternatives (
				member_id, role_id, whoedit 
			) VALUES ~ . (join ', ', @qs) . q~  ; 
		~;
		eval {
			$inscnt = $dbh->do($q);
		};
		$dbh -> do("UNLOCK TABLES ; ");
		
		unless (
			(scalar $inscnt) == (scalar @qs)
		){
			return {
				status => 'fail', 
				message => 'real inserted count does not match expected count. 
					Roles could be inserted not completley.', 
			}
		}
	}

	@qs = ();
	if (scalar @{${$cfg}{'extraslaves'}}) {
		
		$q = qq~
			SELECT 
				u.member_id, 
				r.awp_id, 
				r.sequence AS role_sequence 
			FROM ${SESSION{PREFIX}}users u
				LEFT JOIN ${SESSION{PREFIX}}roles r ON r.role_id=u.role_id 
			WHERE u.member_id = ? ; 
		~;
		
		eval {
			$sth = $dbh -> prepare($q); $sth -> execute($member_id);
			$res = $sth->fetchrow_hashref();
			$sth -> finish();
		};
		return {
			status => 'fail', 
			message => 'member_id is not exist or record damaged', 
		} unless (
			scalar $res -> {'member_id'} &&
			defined($res -> {'awp_id'}) &&
			defined($res -> {'role_sequence'}) 
		);
		
		$q = qq~ 
			SELECT 
				u.member_id 
			FROM ${SESSION{PREFIX}}roles r 
				LEFT JOIN ${SESSION{PREFIX}}users u ON u.role_id=r.role_id 
			WHERE r.awp_id = ~ . $res->{'awp_id'} . qq~
				AND r.sequence>~ . $res->{'role_sequence'} . qq~ 
			ORDER BY r.sequence ASC ; 
		~;
		
		eval {
			$sth = $dbh -> prepare($q); $sth -> execute();
			while ($res = $sth->fetchrow_hashref()) {
			  push @slave_users, $res->{'member_id'};
			}
			$sth -> finish();
		};
		
		foreach my $m_id (scalar @{${$cfg}{'extraslaves'}}) {
			next if (&inarray(\@slave_users, $m_id));
			push @qs , q~ (~ . ($dbh->quote($member_id)) . q~, ~ . 
			($dbh->quote($m_id)) . q~, ~ . 
			($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . q~) ~;
		}

		if (scalar @qs){
			
			$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}users_extrareplaces WRITE ; ");
			
			$q = qq~
				INSERT INTO 
				${SESSION{PREFIX}}users_extrareplaces (
					member_id, slave_id, whoedit 
				) VALUES ~ . (join ', ', @qs) . q~  ; 
			~;
			eval {
				$inscnt = $dbh->do($q);
			};
			$dbh -> do("UNLOCK TABLES ; ");
			
			unless (
				(scalar $inscnt) == (scalar @qs)
			){
				return {
					status => 'fail', 
					message => 'real inserted count does not match expected count. 
						Extra replaces could be inserted not completley or slave by AWP user was there.', 
				}
			}
		}

	}

	return {
		status => 'ok', 
		member_id => $member_id, 
		message => 'All ok', 
	};
} #-- users_add

sub users_edit ($) {
	my $cfg = shift;

	return {
			status => 'fail', 
			message => 'no access to work with users', 
	} unless (
		$SESSION{'USR'}->chk_access('users', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'member_id chk fail',
	} if (
		!defined(${$cfg}{'member_id'}) ||
		${$cfg}{'member_id'} !~ /^\d+$/ 
	); 

	return {
		status => 'fail', 
		message => 'name len fail',
	} unless (
		defined ${$cfg}{'name'} && 
		length ${$cfg}{'name'}
	); 

	return {
		status => 'fail', 
		message => 'roles chk fail',
	} if (
		!defined(${$cfg}{'roles'}) || 
		!(ref ${$cfg}{'roles'}) || 
		!(ref ${$cfg}{'roles'} eq 'ARRAY') || 
		!(scalar @{${$cfg}{'roles'}})  || 
		scalar (grep(/\D/, @{${$cfg}{'roles'}}))
	); 

	if (
		${$cfg}{'lang'} && ${$cfg}{'lang'} ne 'no_lang'		
	){
		return {
			status => 'fail', 
			message => 'lang unknown', 
		} if (
			!&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
		); 
	}
	else {
		${$cfg}{'lang'} = undef;
	}

	${$cfg}{'is_cms_active'} = ${$cfg}{'is_cms_active'}? 1:0;
	${$cfg}{'is_forum_active'} = ${$cfg}{'is_forum_active'}? 1:0;

	my (
		$dbh, $sth, 
		$res, $mres, $rres, $q, 
		@slave_users, @qs, $inscnt, $updcnt 
	) = ($SESSION{'DBH'}, );
	
	$q = qq~
		SELECT 
			u.member_id, u.is_cms_active, 
			u.role_id, u.replace_member_id, 
			r.awp_id, 
			r.sequence AS role_sequence 
		FROM ${SESSION{PREFIX}}users u
			LEFT JOIN ${SESSION{PREFIX}}roles r ON r.role_id=u.role_id 
		WHERE u.member_id = ? ; 
	~;
	
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'member_id'});
		$mres = $sth->fetchrow_hashref();
		$sth -> finish();
	};
	return {
		status => 'fail', 
		message => 'member_id is not exist or record damaged', 
	} unless (
		scalar $mres -> {'member_id'} &&
		defined($mres -> {'role_id'}) &&
		defined($mres -> {'awp_id'}) &&
		defined($mres -> {'role_sequence'}) 
	);

	unless (&inarray(${$cfg}{'roles'}, $mres -> {'role_id'})) {
		$q = qq~
			SELECT  
			r.awp_id, r.role_id, 
			a.sequence AS awp_sequence, 
			r.sequence AS role_sequence 
			FROM ${SESSION{PREFIX}}roles r 
				LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
			WHERE r.role_id IN (~ . (join ', ', @{${$cfg}{'roles'}}) . qq~)
			ORDER BY a.sequence DESC, r.sequence DESC 
			LIMIT 0, 1 ; 
		~;
		
		eval{
			$sth = $dbh -> prepare($q); $sth -> execute();
			$rres = $sth->fetchrow_hashref();
			$sth -> finish();
		};
		return {
			status => 'fail', 
			message => 'new_role is not found', 
		} unless defined($rres -> {'role_id'});
		
		$mres -> {'awp_id'} = $rres -> {'awp_id'};
		$mres -> {'role_id'} = $rres -> {'role_id'};
		$mres -> {'awp_sequence'} = $rres -> {'awp_sequence'};
		$mres -> {'role_sequence'} = $rres -> {'role_sequence'};
		
	}

	$q = qq~ 
		SELECT 
			u.member_id 
		FROM ${SESSION{PREFIX}}roles r 
			LEFT JOIN ${SESSION{PREFIX}}users u ON u.role_id=r.role_id 
		WHERE r.awp_id=~ . $mres->{'awp_id'} . qq~ 
			AND r.sequence>~ . $mres->{'role_sequence'} . qq~ 
		ORDER BY r.sequence ASC ; 
	~;
	eval {
		$sth = $dbh -> prepare($q); $sth -> execute();
		while ($res = $sth->fetchrow_hashref()) {
		  push @slave_users, $res->{'member_id'};
		}
		$sth -> finish();
	};
	
	@qs = ();
	if (scalar @{${$cfg}{'roles'}} > 1) {
		foreach my $role_id (@{${$cfg}{'roles'}}) {
			push @qs , q~ (~ . ($dbh->quote(${$cfg}{'member_id'})) . q~, ~ . 
			($dbh->quote($role_id)) . q~, ~ . 
			($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . q~) ~;
		}
	}
	
	$mres->{'replace_member_id'} = undef unless $mres->{'replace_member_id'} =~ /^\d+$/;
	if (
		$mres->{'replace_member_id'} && 
		!(&inarray([@slave_users, @{${$cfg}{'extraslaves'}}], $mres->{'replace_member_id'}))
	) {
		$mres->{'replace_member_id'} = undef;
	}
	
	$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}users WRITE ; ");
	
	$q = qq~
		UPDATE
		${SESSION{PREFIX}}users 
		SET 
			replace_member_id=~ . ($dbh->quote($mres->{'replace_member_id'})) . qq~, 
			role_id=~ . ($dbh->quote($mres->{'role_id'})) . qq~, 
			name=~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
			site_lng=~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
			whoedit=~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, 
			startpage=~ . ($dbh->quote(${$cfg}{'startpage'})) . qq~ 
		WHERE member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	
	eval {
		$updcnt = $dbh->do($q);
	};
	$dbh -> do("UNLOCK TABLES ; ");
	
	unless (
		scalar $updcnt
	){
		return {
			status => 'fail', 
			message => 'upd users record fail', 
		}
	}
	
	$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}role_alternatives WRITE ; ");
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}role_alternatives 
		WHERE member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~ ; 
	~;
	eval {
		$dbh->do($q);
	};
	
	if (scalar @qs){
		$q = qq~
			INSERT INTO 
			${SESSION{PREFIX}}role_alternatives (
				member_id, role_id, whoedit 
			) VALUES ~ . (join ', ', @qs) . q~  ; 
		~;
		eval {
			$inscnt = $dbh->do($q);
		};
		
		unless (
			(scalar $inscnt) == (scalar @qs)
		){
			return {
				status => 'fail', 
				message => 'real inserted count does not match expected count. 
					Roles could be inserted not completley.', 
			}
		}
	}
	
	$dbh -> do("UNLOCK TABLES ; ");

	@qs = ();
	if (scalar @{${$cfg}{'extraslaves'}}) {
		foreach my $m_id (scalar @{${$cfg}{'extraslaves'}}) {
			next if (&inarray(\@slave_users, $m_id));
			push @qs , q~ (~ . ($dbh->quote(${$cfg}{'member_id'})) . q~, ~ . 
			($dbh->quote($m_id)) . q~, ~ . 
			($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . q~) ~;
		}
	}
	
	$dbh -> do("LOCK TABLES ${SESSION{PREFIX}}users_extrareplaces WRITE ; ");
	
	$q = qq~
		DELETE 
		FROM ${SESSION{PREFIX}}users_extrareplaces 
		WHERE member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~ ; 
	~;
	eval {
		$dbh->do($q);
	};
	
	if (scalar @qs){
		$q = qq~
			INSERT INTO 
			${SESSION{PREFIX}}users_extrareplaces (
				member_id, slave_id, whoedit 
			) VALUES ~ . (join ', ', @qs) . q~  ; 
		~;
		eval {
			$inscnt = $dbh->do($q);
		};
		
		unless (
			(scalar $inscnt) == (scalar @qs)
		){
			return {
				status => 'fail', 
				message => 'real inserted count does not match expected count. 
					Extra replaces could be inserted not completley or slave by AWP user was there.', 
			}
		}
	}
	
	$dbh -> do("UNLOCK TABLES ; ");

	if (
		${$cfg}{'email'} && 
		length ${$cfg}{'email'}
	){
		unless ($SESSION{'USR'}->change_email(${$cfg}{'email'}, ${$cfg}{'member_id'})){
			return {
				status => 'fail', 
				message => 'email is not changed: ' . $SESSION{'USR'}->{'last_state'}, 
			}
		}
	}

	if (
		${$cfg}{'password'} && 
		length ${$cfg}{'password'} && 
		${$cfg}{'password_retype'} && 
		length ${$cfg}{'password_retype'} 
	){
		unless (
			$SESSION{'USR'}->change_password(
				${$cfg}{'password'}, 
					${$cfg}{'password_retype'}, 
						${$cfg}{'member_id'})
		){
			return {
				status => 'fail', 
				message => 'password is not changed: ' . $SESSION{'USR'}->{'last_state'}, 
			}
		}
	}
	
	if (${$cfg}{'is_cms_active'} != $mres -> {'is_cms_active'}) {
		unless (
			$SESSION{'USR'}->set_cms_active(
				${$cfg}{'is_cms_active'}, 
						${$cfg}{'member_id'})
		){
			return {
				status => 'fail', 
				message => 'cms active is not changed: ' . $SESSION{'USR'}->{'last_state'}, 
			}
		}
	}
	
	unless (
		$SESSION{'USR'}->set_forum_active(
			${$cfg}{'is_forum_active'},
					${$cfg}{'member_id'})
	){
		return {
			status => 'fail', 
			message => 'forum active is not changed: ' . $SESSION{'USR'}->{'last_state'}, 
		}
	}
	
	return {
		status => 'ok', 
		member_id => ${$cfg}{'member_id'}, 
		message => 'All ok', 
	};
} #-- users_edit

sub users_delete ($) {
	my $cfg = shift;
	
	return {
			status => 'fail', 
			message => 'no access to work with users', 
	} unless (
		$SESSION{'USR'}->chk_access('users', 'manage', 'w') 
	);
	
	return {
			status => 'fail', 
			message => 'no input cfg', 
	} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

	return {
		status => 'fail', 
		message => 'member_id chk fail',
	} if (
		!defined(${$cfg}{'member_id'}) ||
		${$cfg}{'member_id'} !~ /^\d+$/ 
	); 
	
	my (
		$dbh, $q , 
		
	) = ($SESSION{'DBH'}, );
	
	$dbh -> do(qq~
		LOCK TABLES ${SESSION{FORUM_PREFIX}}members WRITE, 
			${SESSION{PREFIX}}users WRITE, 
			${SESSION{PREFIX}}sessions WRITE, 
			${SESSION{PREFIX}}role_alternatives WRITE, 
			${SESSION{PREFIX}}users_extrareplaces WRITE ; 
	~);
	
	$q = qq~
		DELETE FROM ${SESSION{FORUM_PREFIX}}members 
		WHERE ID_MEMBER = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	eval { $dbh->do($q); };
	
	$q = qq~
		DELETE FROM ${SESSION{PREFIX}}sessions 
		WHERE member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	eval { $dbh->do($q); };
	
	$q = qq~
		DELETE FROM ${SESSION{PREFIX}}role_alternatives 
		WHERE member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	eval { $dbh->do($q); };
	
	$q = qq~
		DELETE FROM ${SESSION{PREFIX}}users_extrareplaces 
		WHERE users_extrareplaces = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	eval { $dbh->do($q); };
	
	$q = qq~
		UPDATE ${SESSION{PREFIX}}users 
		SET replace_member_id = NULL 
		WHERE replace_member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	eval { $dbh->do($q); };
	
	$q = qq~
		DELETE FROM ${SESSION{PREFIX}}users 
		WHERE member_id = ~ . ($dbh->quote(${$cfg}{'member_id'})) . qq~  ;
	~;
	eval { $dbh->do($q); };
	
	$dbh -> do("UNLOCK TABLES ; ");
	
	return {
		status => 'ok', 
		member_id => ${$cfg}{'member_id'}, 
		message => 'All ok', 
	};
} #-- users_delete

1;
