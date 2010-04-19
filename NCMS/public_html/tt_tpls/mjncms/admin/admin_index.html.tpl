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
            <a href="/"><span style="font-size:1.15em; font-weight:bolder; text-transform: uppercase;">Mojolicious-based PERL NOT CMS :)</span></a>
                </td>
                <td class="catbg rmal" style="padding:0.2em 0.7em 0.2em 0.2em;">
                    <a href="/"><span style="font-size:1.15em; font-weight:bolder;">MjNCMS</span></a>
                </td>
            </tr>
            <tr id="upshrinkHeader" style='display:[% topblock_display %];'>
                <td valign="top" colspan="4">
                    <table width="100%" class="bordercolor" cellpadding="8" cellspacing="0" border="0">
                        <tr>
                            <td class="windowbg2" width="100%" valign="top">
                                [%- UNLESS SESSION.USR.member_id %]
                                    [%# INCLUDE admin/admin_auth.tpl %]
                                    <b>[% loc('No auth') %].</b>
                                [% ELSE -%]
                                        [% loc('Hello') %], 
                                            <strong>
                                            [%- IF 
                                                #SESSION.USR.chk_access('users', 'switch_user') && 
                                                SESSION.USR.slave_users_ids && 
                                                SESSION.USR.slave_users_ids.size>1 
                                            -%]
                                                    <a title="[% loc('You can switch user') %]" class="hp" href="#" onClick="javascript:show_usersw_form();return false;">[% END %]
                                                    [% SESSION.USR.profile.member_name | html %]
                                            [%- IF 
                                                #SESSION.USR.chk_access('users', 'switch_user') && 
                                                SESSION.USR.slave_users_ids && 
                                                SESSION.USR.slave_users_ids.size>1 
                                            %]</a>[% END %]
                                            </strong>, 
                                            [%- IF 
                                                #SESSION.USR.chk_access('users', 'switch_role') && 
                                                SESSION.USR.role_alternatives && 
                                                SESSION.USR.role_alternatives.size>1 
                                            -%]
                                                <a title="[% loc('You can switch AWP:Role combo') %]" class="hp" href="#" onClick="javascript:show_rolesw_form();return false;">
                                            [% END -%]
                                            Your workplace:
                                                <b>[%- SESSION.USR.awp_name | html -%]</b>
                                            | Your role: 
                                                <b>[%- SESSION.USR.role_name | html -%]</b>
                                            [%- IF 
                                                #SESSION.USR.chk_access('users', 'switch_role') && 
                                                SESSION.USR.role_alternatives && 
                                                SESSION.USR.role_alternatives.size>1 
                                            %]</a>[% END -%]
                                            <br />
                                    <span class="nwp">Today <strong>[% SESSION.today_date %]&nbsp;</strong>, Your time: <b>[% SESSION.localtime %]&nbsp;</b> | [% INCLUDE common/common_logout.tpl referer=SESSION.ADM_URL %]</span>
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
                    [% ELSE #IF mids_data.${mid}.link == SESSION.CURRENT_PAGE -%]
                        <td valign="top" class="maintab_back"><a href="[% bytestream(mids_data.${mid}.link, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]">[% mids_data.${mid}.text %]</a></td>
                    [% END #IF mids_data.${mid}.link == SESSION.CURRENT_PAGE -%]
            [% END #FOREACH -%]
            <td class="maintab_last">
                <img src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/1x1.gif" style="width:1px;height:1px;" />
            </td>
        </tr>
    </table>
    [%- IF 
        #SESSION.USR.chk_access('users', 'switch_user') && 
        SESSION.USR.slave_users_ids && 
        SESSION.USR.slave_users_ids.size>1 
    -%]
        [% user_swdata = BLOCK -%]
            <form action="[% SESSION.USR_URL | html %]/user_sw" method="post" accept-charset="[% TT_VARS.html_charset %]">
                <table border="0" cellspacing="1" cellpadding="4" class="bordercolor w100">
                [% u_savle_role='' -%]
                [% FOREACH u=SESSION.USR.slave_users -%]
                    [% IF u.role_id!=u_savle_role -%]
                        <tr class="catbg3">
                            <td colspan="2" class="lmal">
                                [% u.awp_name | html %]\[% u.role_name | html %]
                            </td>
                        </tr>
                    [% END -%]
                        <tr 
                            onclick="javascript:$('midsw_[% u.member_id %]').checked=true;" 
                            onmouseout="javascript:var myid=this.id;$(myid).set({'class':$('midsw_[% u.member_id %]').get('class')});" 
                            onmouseover="javascript:var myid=this.id;$(myid).set({'class':'status_accepted'});" 
                            style="cursor:hand;cursor:pointer;" id="r_midsw_[% u.member_id %]" class="nwp windowbg[% IF SESSION.USR.member_id==u.member_id %] status_indelivery[% END %]"
                        >
                            <td class="w15">
                                <input type="radio" value="[% u.member_id %]" name="midsw" id="midsw_[% u.member_id %]" class="windowbg[% IF SESSION.USR.member_id==u.member_id %] status_indelivery" checked="checked"[% ELSE %]"[% END %]/>
                            </td>
                            <td>
                                [% '<b>' IF SESSION.USR.member_id==u.member_id %][% u.name | html %][% '</b>' IF SESSION.USR.member_id==u.member_id %]
                            </td>
                        </tr>
                [% END %]
                </table>
                <br />
                <div class="rmal rpad"><input type="submit" value="&nbsp;&nbsp;[% loc('Switch user') %]&nbsp;&nbsp;" /></div>
                <input type="hidden" name="referer" value="[% SESSION.CURRENT_PAGE | html %]" />
            </form>
        [% END # BLOCK -%]
    [%- END # IF SESSION.USR.slave_users_ids.size -%]
    [%- IF 
        #SESSION.USR.chk_access('users', 'switch_role') && 
        SESSION.USR.role_alternatives && 
        SESSION.USR.role_alternatives.size>1 
    -%]
        [% role_swdata = BLOCK -%]
            <form action="[% SESSION.USR_URL | html %]/role_sw" method="post" accept-charset="[% TT_VARS.html_charset %]">
                <table cellspacing="1" cellpadding="4" border="0" class="bordercolor w100">
                    [% FOREACH r=SESSION.USR.role_alternatives -%]
                        <tr 
                            onclick="javascript:$('ridsw_[% r.role_id %]').checked=true;" 
                            onmouseout="javascript:var myid=this.id;$(myid).set({'class':$('ridsw_[% r.role_id %]').get('class')});" 
                            onmouseover="javascript:var myid=this.id;$(myid).set({'class':'status_accepted'});" 
                            style="cursor:hand; cursor: pointer;" id="r_ridsw_[% r.role_id %]" class="nwp windowbg[% IF SESSION.USR.role_id==r.role_id %] status_indelivery[% END %]"
                        >
                            <td>
                                <input type="radio" value="[% r.role_id %]" name="ridsw" id="ridsw_[% r.role_id %]" class="windowbg[% IF SESSION.USR.role_id==r.role_id %] status_indelivery" checked="checked"[% ELSE %]"[% END %]/>
                            </td>
                            <td>
                                [% '<b>' IF SESSION.USR.role_id==r.role_id %][% r.awp_name | html %]\[% r.role_name | html %][% '</b>' IF SESSION.USR.role_id==r.role_id %]
                            </td>
                        </tr>
                    [% END #FOREACH -%]
                </table><br />
                <div class="rmal rpad"><input type="submit" value="&nbsp;&nbsp;[% loc('Switch AWP/Role combo') %]&nbsp;&nbsp;" /></div>
                <input type="hidden" name="referer" value="[% SESSION.CURRENT_PAGE | html %]" />
            </form>
        [% END # BLOCK -%]
    [%- END # IF SESSION.USR.role_alternatives.size -%]
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
                        [% loc('No auth') -%]<br />
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
    [% IF user_swdata %]<div id="user_sw_form_div" class="iv">[% user_swdata %]</div>[% END -%]
    [% IF role_swdata %]<div id="role_sw_form_div" class="iv">[% role_swdata %]</div>[% END -%]
[% END #UNLESS SESSION.REQ_ISAJAX -%]
