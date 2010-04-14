[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX -%]
	[% TT_VARS.CSS.push(SESSION.THEME_URLPATH _ '/_static/css/main.css10') -%]
	[% TT_VARS.CSS.push(SESSION.THEME_URLPATH _ '/_static/css/page.css20') -%]
	[% TT_VARS.CSS.push(SESSION.FORUM_URL _ '/Themes/default/style.css30') -%]
	[% TT_VARS.CSS.push(SESSION.THEME_URLPATH _ '/_static/js/assets/themes/crispin/jxtheme.uncompressed.css50') -%]
	[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/mootools.js10') -%]
	[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/mootools-more.js15') -%]
	[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/jxlib.js20') -%]
	[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/mootools-local.js25') -%]
[% END -%]
[% tt_controller=TT_VARS.tt_controller -%]
[% tt_action=TT_VARS.tt_action -%]
[% UNLESS SESSION.USR.member_id -%]
	[% tt_controller='admin' -%]
	[% tt_action='auth' -%]
[% END #UNLESS SESSION.USR.member_id -%]
[% TT_CALLS.register_tt_call('menus', 'menus_get_record') -%]
[% TT_CALLS.register_tt_call('menus', 'menus_get_record_tree') -%]
[% TT_CALLS.register_tt_call('menus', 'menus_get_parent_tree') -%]
[% UNLESS SESSION.REQ_ISAJAX -%]
	<script type="text/javascript" language="javascript">
		
		if(!mj_sys_vals){
			var mj_sys_vals = new Hash();
		}
		
		mj_sys_vals.set('mjadm_url', '[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]');
		mj_sys_vals.set('theme_url', '[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]');
		MooTools.lang.setLanguage('ru-RU-unicode');
		MooTools.lang.set('ru-RU-unicode', 'cascade', ['ru-RU-unicode', 'en-US']);
	</script>
		[% IF TT_VARS.MSG -%]
			<table style='width:100%;border:2px solid green;margin-top:4px;margin-bottom:4px;' cellpadding='0' cellspacing='0'>
				<tr>
					<td style='vertical-align:middle;text-align:center;background-color:#c1e5b0;height:60px;'>
						<b>[% loc(TT_VARS.MSG) | html %]</b>
					</td>
				</tr>
			</table>
			<br />
		[% END -%]
	<div class="tborder" >
	
		<table width="100%" cellpadding="0" cellspacing="0" border="0" >
			<tr>
				<td class="catbg lmal" style="padding:0.2em 0.2em 0.2em 0.7em;">
			<span style="font-size:1.15em; font-weight:bolder; text-transform: uppercase;">Mojolicious-based PERL CMS</span>
				</td>
				<td class="catbg rmal" style="padding:0.2em 0.7em 0.2em 0.2em;">
					<span style="font-size:1.15em; font-weight:bolder; text-transform: uppercase;">MjNCMS</span>
				</td>
			</tr>
			<tr id="upshrinkHeader" style='display:[% topblock_display %];'>
				<td valign="top" colspan="4">
					<table width="100%" class="bordercolor" cellpadding="8" cellspacing="0" border="0">
						<tr>
							<td class="windowbg2" width="100%" valign="top">
								[%- UNLESS SESSION.USR.member_id %]
									[%# INCLUDE admin/admin_auth.tpl %]
									<b>[% loc('You are not authorized') %].</b>
								[% ELSE -%]
										[% loc('Hello') %], 
											<strong>[% IF SESSION.USR.slave_users.size %]<a title="[% loc('You can switch user') %]" class="hp" href="#" onClick="javascript:return makeUserSelect();">[% END %][% SESSION.USR.profile.member_name | html %][% IF SESSION.USR.slave_users.size %]</a>[% END %]</strong>, 
											Your workplace:
												<b>[%- SESSION.USR.awp_name | html -%]</b>
											| Your role: 
											[%- IF SESSION.USR.role_alternatives.keys.size %]<a title="[% loc('You can switch AWP:Role combo') %]" class="hp" href="#" onClick="javascript:init_rolesw();return false;">[% END -%]
												<b>[%- SESSION.USR.role_name | html -%]</b>
											[%- IF SESSION.USR.role_alternatives.keys.size %]</a>[% END -%]
											<br />
									<span class="nwp">Today <strong>[% SESSION.today_date %]</strong>, Your time: <b>[% SESSION.localtime %]</b> | [% INCLUDE admin/admin_logout.tpl referer=SESSION.ADM_URL %]</span>
								[%- END -%]
							</td>
							<td class="windowbg2" style="padding:0;">
								&nbsp;
							</td>
							<td align="right" class="windowbg2">
								&nbsp;<!-- logo here -->
							</td>
							<td class="windowbg2" style="padding:0px 5px 0px 0px;">
								&nbsp;<!-- little add/msg here -->
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<table cellpadding="0" cellspacing="0" border="0" style="margin-left: 10px;">
		<tr>
			<td class="maintab_first">
				<img src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/1x1.gif" style="width:1px;height:1px;" />
			</td>
			[% mids = TT_CALLS.menus_get_record_tree('mjncmsadm') -%]
			[% mids_data = TT_CALLS.menus_get_record(mids).records -%]
			[% FOREACH mid=mids -%]
					[% IF mids_data.${mid}.link == SESSION.CURRENT_PAGE -%]
						<td class="maintab_active_first">&nbsp;</td>
							<td valign="top" class="maintab_active_back"><a href="[% bytestream(mids_data.${mid}.link, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]">[% mids_data.${mid}.text %]</a></td>
						<td class="maintab_active_last">&nbsp;</td>
					[% ELSE #IF item.href -%]
						<td valign="top" class="maintab_back"><a href="[% bytestream(mids_data.${mid}.link, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]">[% mids_data.${mid}.text %]</a></td>
					[% END #IF item.href -%]
			[% END #FOREACH -%]
			<td class="maintab_last">
				<img src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/1x1.gif" style="width:1px;height:1px;" />
			</td>
		</tr>
	</table>
	[%- IF SESSION.USR.role_alternatives.keys.size -%]
		[% role_swdata = BLOCK -%]
			<form action="/cgi-bin/do.cgi" method="post" accept-charset="[% settings.charset %]">
			<table cellspacing="1" cellpadding="4" border="0" class="bordercolor">
				[% FOREACH rid=settings.role_alternatives.keys.nsort -%]
				<tr onclick="javascript:$('ridsw_[% rid %]').checked=true;" onmouseout="javascript:var myid=this.id;$(myid).set({'class':$('ridsw_[% rid %]').get('class')});" onmouseover="javascript:var myid=this.id;$(myid).set({'class':'status_accepted'});" style="cursor: pointer; white-space: nowrap;" id="r_ridsw_[% rid %]" class="windowbg[% IF settings.role_id==rid %] status_indelivery[% END %]">
					<td><input type="radio" value="[% rid %]" name="ridsw" id="ridsw_[% rid %]" class="windowbg[% IF settings.role_id==rid %] status_indelivery[% END %]"[% IF settings.role_id==rid %] checked="checked"[% END %]/></td>
					<td>[% settings.role_alternatives.$rid | html %]</td>
				</tr>
				[% END #FOREACH-%]
			</table>
			<br /><input type="submit" value="OK" />
			<input type="hidden" name="referer" value="[% settings.currentpage | html %]" />
			<input type="hidden" name="action" value="role_sw" />
			<input type="hidden" name="mod" value="timdb_common" /></form>
		[% END # BLOCK -%]
		[% INCLUDE common/popuplayer.tpl t_root_id='role_sw', t_content=role_swdata, t_title='Смена роли' -%]
		<script type="text/javascript" language="javascript">
		function init_rolesw(){
			open_popup_layer('role_sw_popup');
		}
		</script>
	[%- END # IF SESSION.USR.role_alternatives.keys.size -%]
	[%- IF SESSION.USR.awp_alternatives.keys.size -%]
		[% arm_swdata= BLOCK -%]
			<form action="/cgi-bin/do.cgi" method="post" accept-charset="[% settings.charset %]">
			<table cellspacing="1" cellpadding="4" border="0" class="bordercolor">
				[% FOREACH aid=settings.arm_alternatives.keys.nsort -%]
				<tr onclick="javascript:$('aidsw_[% aid %]').checked=true;" onmouseout="javascript:var myid=this.id;$(myid).set({'class':$('aidsw_[% aid %]').get('class')});" onmouseover="javascript:var myid=this.id;$(myid).set({'class':'status_accepted'});" style="cursor: pointer; white-space: nowrap;" id="r_aidsw_[% aid %]" class="windowbg[% IF settings.arm_id==aid %] status_indelivery[% END %]">
					<td><input type="radio" value="[% aid %]" name="armsw" id="aidsw_[% aid %]" class="windowbg[% IF settings.arm_id==aid %] status_indelivery[% END %]"[% IF settings.arm_id==aid %] checked="checked"[% END %]/></td>
					<td>[% settings.arm_alternatives.$aid | html %][%  IF (settings.st_pid || settings.is_sysadm) && aid==settings.adm_armnum -%]
					: [% INCLUDE common/schools.tpl t_name='school_id', t_selected=settings.school_id, t_st_pid=settings.st_pid %]<br />
					[% END %]</td>
				</tr>
				[% END #FOREACH-%]
			</table>
			<br /><input type="submit" value="OK" />
			<input type="hidden" name="referer" value="[% settings.currentpage | html %]" />
			<input type="hidden" name="action" value="arm_sw" />
			<input type="hidden" name="mod" value="timdb_common" /></form>
		[% END # BLOCK -%]
		[% INCLUDE common/popuplayer.tpl t_root_id='arm_sw', t_content=arm_swdata, t_title='Смена рабочего места' -%]
		<script type="text/javascript" language="javascript">
		function init_awpsw(){
			open_popup_layer('awp_sw_popup');
		}
		</script>
	[%- END #IF SESSION.USR.awp_alternatives.keys.size -%]

	<table width="100%" cellpadding="0" cellspacing="0" border="0" style="padding-top: 1ex;">
			[% IF !tt_controller || !tt_action -%]
				<tr>
					<td colspan="2">
						[% loc('Some or both tt vars is not defined!') -%]<br />
						<b>tt_controller:</b> '[% tt_controller | html %]'<br />
						<b>tt_action:</b> '[% tt_action | html %]'<br />
						[% loc('Setting them to default admin:index now!') -%]<br />
					</td>
				</tr>
				[% tt_controller='admin' -%]
				[% tt_action='index' -%]
			[% END #IF !tt_controller || !tt_action -%]
		<tr>
				<td width="150" class="vat" style="width: 23ex; padding-right: 10px; padding-bottom: 10px;" id="nl_canvas">
					[% UNLESS tt_action=='auth' %]
						[% TRY -%]
							[% prs_tplname = tt_controller _ '/' _ tt_controller _ '_navleft.tpl' -%]
							[% INCLUDE $prs_tplname -%]
						[% CATCH -%]
							[% loc('Error') -%]: [% loc('Unable load nav template.') -%]<br />
							<b>tt_controller:</b> '[% tt_controller | html %]'<br />
							<b>tt_action:</b> '[% tt_action | html %]'<br />
							[% prs_tplname = tt_controller _ '/' _ tt_controller _ '_navleft.tpl' -%]
							<b>tpl file to include:</b> '[% prs_tplname | html %]'<br />
							[% IF error %][% loc('Error text') -%]: <i>[% error.info | html -%]</i>[% END -%]
						[% END -%]
					[% ELSE -%]
						[% loc('You are not authorized.') -%]<br />
					[% END -%]
				</td>
				<td class="vat">
[% ELSE #UNLESS SESSION.REQ_ISAJAX -%]
	[% TT_VARS.make_it_simple=1 -%]
[% END #UNLESS SESSION.REQ_ISAJAX -%]
				[% TRY -%]
					[% prs_tplname = tt_controller _ '/' _ tt_controller _ '_' _ tt_action _ '.tpl' -%]
					[% INCLUDE $prs_tplname -%]
				[% CATCH -%]
					[% loc('Error') -%]: [% loc('Unable load action template.') -%]<br />
					<b>tt_controller:</b> '[% tt_controller | html %]'<br />
					<b>tt_action:</b> '[% tt_action | html %]'<br />
					[% prs_tplname = tt_controller _ '/' _ tt_controller _ '_' _ tt_action _ '.tpl' %]
					<b>tpl file to include:</b> '[% prs_tplname | html %]'<br />
					[% IF error %][% loc('Error text') -%]: <i>[% error.info | html -%]</i>[% END -%]
				[% END -%]
[% UNLESS SESSION.REQ_ISAJAX -%]
				</td>
		</tr>
	</table>

	<table cellspacing="0" cellpadding="3" border="0" align="center" width="100%">
		<tr>
			<td width="28%" valign="middle" align="right">
				<img src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/1x1.gif" style="width:1px;height:1px;" />
			</td>
			<td valign="middle" align="center" style="white-space: nowrap;">
				<span style="font-size:0.83em;" class="nwp">
					<span style="color:#496d91;"><b>MjNCMS<sup><s>&reg;</s> :)</sup></b></span>
					2010 &copy; <a href="http://lefedor.blogspot.com/" target="_blank">FedorFL</a> (<a href="http://maps.google.com/?ie=UTF8&amp;t=h&amp;ll=59.864125,30.423889&amp;spn=34.603775,83.496094&amp;z=4" target="_blank">Russia/Saint-Petersburg</a>)
				</span>
			</td>
			<td width="28%" valign="middle" align="left">
				<img src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/1x1.gif" style="width:1px;height:1px;" />
			</td>
		</tr>
	</table>

	<div id="body_tmp_container">&nbsp;</div>
[% END #UNLESS SESSION.REQ_ISAJAX -%]
