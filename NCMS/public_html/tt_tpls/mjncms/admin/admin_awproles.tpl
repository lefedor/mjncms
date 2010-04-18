[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/awp_roles.js') -%]
[% colspan=4 -%]
[% res=TT_CALLS.awproles_get() -%]
[% IF res.message -%]
    [% loc('AWP / Roles list receiving fail') | html -%]:[% res.message | html -%]
    [% RETURN -%]
[% END -%]
[%# res.qr -%]
[%# res.qa -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;">
                <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/add_awp?rnd=[% SESSION.RND %]" onClick="javascript:show_addperm_form();return false;" class="hp" title="[% loc('Automated WorkPlace') %]">[+ [% loc('Add AWP') %]]</a>
                <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/add_role?rnd=[% SESSION.RND %]" onClick="javascript:show_addperm_form();return false;">[+ [% loc('Add wps\'s role') %]]</a>
            </span>[% loc('Automated WorkPlaces/Roles management') -%]
        </td>
    </tr>
</table>
    [% IF res.awps_seq_list.size -%]
            <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="awproles_list_table">
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
                    <td class="w5">[% loc('Id') | html %]</td>
                    <td class="lmal">[% loc('Name') | html %]</td>
                    <td class="w5">[% loc('Sequence') | html %]</td>
                    <td class="w10">[% loc('Actions') | html %]</td>
                </tr>
                
                [% FOREACH awp=res.awps_seq_list -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                    <tr class="windowbg[% row_sw %]" id="awplist_tr_[% awp %]">
                        <td class="cmal">
                            [% awp -%]
                        </td>
                        <td class="lmal">
                            [% res.awps.$awp.name | html -%]
                        </td>
                        <td class="lmal">
                            [% res.awps.$awp.sequence -%]
                        </td>
                        <td class="cmal">
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/edit_awp/[% awp -%]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit awp') %]" title="[% loc('Edit awp') %]" /></a>
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/setperm_awp/[% awp %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/config_sm.gif" alt="[% loc('Set awp permissions') %]" title="[% loc('Set awp permissions') %]" /></a>
                            <a onClick="javascript:return confirm('[% loc('Delete awp') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/delete_awp/[% awp %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete awp') %]" title="[% loc('Delete awp') %]" /></a>
                        </td>
                    </tr>
                    [% FOREACH role=res.roles_seq_list.${awp} -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                        <tr class="windowbg[% row_sw %]" id="rolelist_tr_[% role -%]">
                            <td class="cmal">
                                [% role -%]
                            </td>
                            <td class="lmal">
                                &nbsp;&nbsp;&nbsp;<sup>L</sup> [% res.roles.$role.name | html -%]
                            </td>
                            <td class="lmal">
                                [% res.roles.$role.sequence -%]
                            </td>
                            <td class="cmal">
                                <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/edit_role/[% role %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit category') %]" title="[% loc('Edit page') %]" /></a>
                                <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/setperm_role/[% role %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/config_sm.gif" alt="[% loc('Set role permissions') %]" title="[% loc('Set role permissions') %]" /></a>
                                <a onClick="javascript:return confirm('[% loc('Delete role') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/delete_role/[% role %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete role') %]" title="[% loc('Delete role') %]" /></a>
                            </td>
                        </tr>
                    [% END #FOREACH role=res.roles_seq_list.${awp.awp_id} -%]
                [% END #FOREACH awp=res.awps_seq_list -%]
            </table>
    [% ELSE #IF res.awps_seq_list.size -%]
        <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
            <tr class="windowbg">
                <td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                    [% loc('No AWP/Roles found in database') -%]
                </td>
            </tr>
        </table>
    [% END #IF res.awps_seq_list.size -%]
<script type="text/javascript" language="javascript">

    //locale_permissions.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
