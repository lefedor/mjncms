[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/permissions.js') -%]
[% colspan=7 -%]
[% res=TT_CALLS.users_get({
    'name' => SESSION.REQ.param('nm'),
    'login' => SESSION.REQ.param('lgn'), 
    'incl_notincms' => SESSION.REQ.param('nic'), 
    'is_forum_active' => SESSION.REQ.param('isa'), 
    'is_cms_active' => SESSION.REQ.param('isac'), 
    'page' => SESSION.REQ.param(SESSION.PAGER_PAGEARG), 
    
}) -%]
[% IF res.message -%]
    [% loc('Permissions list receiving fail') | html -%]:[% res.message | html -%]
    [%# RETURN -%]
[% END -%]
[%# res.q -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/users/add?rnd=[% SESSION.RND %]" onClick="javascript:show_adduser_form();return false;">[+ [% loc('Add new') | html %]]</a></span>[% loc('Users management') -%]
        </td>
    </tr>
    <tr class="windowbg">
        <td>
            <form name="filters_users_frm" id="filters_users_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/users" method="get" accept-charset="[% TT_VARS.html_charset %]">
                <table>
                    <tr>
                        <td>
                            <label for="filter_usr_login">[% loc('Login') | html -%]: </label>
                        </td>
                        <td>
                        <input type="text" name="lgn" id="filter_usr_login" size="16" value="[% SESSION.REQ.param('lgn') | html %]"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="filter_usr_name">[% loc('Name') | html-%]: </label>
                        </td>
                        <td>
                            <input type="text" name="nm" id="filter_usr_name" size="16" value="[% SESSION.REQ.param('nm') | html %]"/>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="checkbox" name="isac" value="1" id="filter_usr_isac"[% IF SESSION.REQ.param('isac') %] checked="checked"[% END %] class="vam"/><label for="filter_usr_isac">[% loc('Only active (CMS)') | html -%]</label>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="checkbox" name="isa" value="1" id="filter_usr_isa"[% IF SESSION.REQ.param('isa') %] checked="checked"[% END %] class="vam"/><label for="filter_usr_isa">[% loc('Only active (Forum)') | html -%]</label>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="checkbox" name="nic" value="1" id="filter_usr_nic"[% IF SESSION.REQ.param('nic') %] checked="checked"[% END %] class="vam"/><label for="filter_usr_nic">[% loc('Add users in forum, but not in CMS') | html -%]</label>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="submit" value="[% loc('Filter user list') | html %]" />
                        </td>
                    </tr>
                </table>
                <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
            </form>
        </td>
    </tr>
</table>
    [% IF res.users.size -%]
            <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="awproles_list_table">
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="catbg3 nwp b cmal">
                    <td class="w5">[% loc('Id') | html %]</td>
                    <td class="w15 lmal">[% loc('Login') | html %]</td>
                    <td class="lmal">[% loc('Name') | html %]</td>
                    <td class="w30 lmal">[% loc('Role') | html %]</td>
                    <td class="cmal w5 hp" title="[% loc('Is CMS user') | html %]?">[% loc('isU') | html %]</td>
                    <td class="cmal w5 hp" title="[% loc('Is active @ forum') | html %]?">[% loc('isA') | html %]</td>
                    <td class="w10">[% loc('Actions') | html %]</td>
                </tr>
                [% IF res.pages.count>1 -%]
                    <tr>
                        <td class="titlebg"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                            [% INCLUDE common_pager_simple.tpl pages=res.pages %]
                        </td>
                    </tr>
                [% END #IF res.pages.count>1 -%]
                [% FOREACH usr=res.users -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                    <tr class="windowbg[% row_sw %]" id="usrlist_tr_[% usr.member_id %]">
                        <td class="cmal">
                            [% usr.member_id -%]
                        </td>
                        <td class="lmal">
                            [% usr.login | html -%]
                        </td>
                        <td class="lmal">
                            [% IF usr.name -%]
                                [% usr.name | html -%]
                            [% ELSE -%]
                                [% usr.forum_name | html %] ([% loc('Forum name') | html %])
                            [% END -%]
                        </td>
                        <td class="lmal">
                            [% IF usr.is_cmsuser -%]
                                [% usr.awp_name | html -%]<b>/</b>[% usr.role_name | html -%]
                            [% ELSE -%]
                                &nbsp;-
                            [% END -%]
                        </td>
                        <td class="cmal[% UNLESS usr.is_cms_active %] hp" title="[% loc('User banned @ CMS') | html %]"[% ELSE %]"[% END %]>
                            [% IF usr.is_cmsuser -%]
                                [% IF usr.is_cms_active %]1[% ELSE %]<b>B</b>[% END -%]
                            [% ELSE %]0[% END -%]
                        </td>
                        <td class="cmal">
                            [% IF usr.is_forum_active %]1[% ELSE %]0[% END -%]
                        </td>
                        <td class="cmal">
                            [% IF usr.is_cmsuser %]
                                <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/users/edit/[% usr.member_id -%]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/_static/gfx/reply.gif" alt="[% loc('Edit user') | html %]" title="[% loc('Edit user') | html %]" /></a>
                                <a onClick="javascript:return confirm('[% loc('Delete user from CMS') | html %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/users/delete/[% usr.member_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/_static/gfx/delete.gif" alt="[% loc('Delete user from CMS') | html %]" title="[% loc('Delete user from CMS') | html %]" /></a>
                            [% ELSE -%]
                                <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/users/edit/[% usr.member_id -%]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/_static/gfx/normal_blank_sticky.gif" alt="[% loc('Edit permission') | html %]" title="[% loc('Forum user to CMS') | html %]" /></a>
                            [% END -%]
                        </td>
                    </tr>
                [% END #FOREACH page=pages.pages_res -%]
                [% IF res.pages.count>1 -%]
                    <tr>
                        <td class="titlebg"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                            [% INCLUDE common_pager_simple.tpl pages=res.pages %]
                        </td>
                    </tr>
                [% END #IF res.pages.count>1 -%]
            </table>
    [% ELSE #IF res.users.size -%]
        <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
            <tr class="windowbg">
                <td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                    [% loc('No users found in database') | html -%]
                </td>
            </tr>
        </table>
    [% END #IF res.users.size -%]
<script type="text/javascript" language="javascript">

    //locale_permissions.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
