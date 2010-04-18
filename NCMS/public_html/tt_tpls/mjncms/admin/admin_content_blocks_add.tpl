[% USE loc -%]
[% USE bytestream -%]
[% colspan=2 -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/blocks.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_add_block_subm();return false;[% ELSE %]return confirm('[% loc('Add block') | html %]?');[% END %]" name="save_new_cat_frm" id="save_new_block_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/add" method="post" accept-charset="[% TT_VARS.html_charset %]">
    <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
        <tr class="titlebg">
            <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
                [% loc('Create new block') | html -%]
            </td>
        </tr>
        <tr class="windowbg">
            <td class="windowbg lual" style="padding: 7px;">
                    <label for="block_alias" title="[% loc('Up to 32 chars, to call from template by alias, not by id') | html %]">[% loc('Block alias') | html %]: </label><input type="text" name="block_alias" id="block_alias" size="14" maxlength="32" /><br />
                    <input type="checkbox" name="block_isactive" id="block_isactive" value="1" class="vam" checked="checked"/>
                        <label for="block_isactive">[% loc('Is active') | html %]</label><br />
                    <label for="block_lang">[% loc('Block default lng') | html %]:</label> 
                        [% INCLUDE common_langlist_fmt.tpl 
                            t_name='block_lang', 
                            t_anylang=1,
                            t_selected={ ${SESSION.USR.member_sitelng} => 1 } 
                        -%]
                        <br /><br />
                    <label for="block_header" title="[% loc('Up to 64 chars') | html %]">[% loc('Block header') | html %]: </label>
                        <input type="text" name="block_header" id="block_header" size="14" maxlength="64" />
                    <input type="checkbox" name="block_show_header" id="block_show_header" value="1" class="vam" checked="checked"/>
                        <label for="block_show_header" title="[% loc('Show header') | html %]">[% loc('Show') | html %]</label><br />
                        <label title="[% loc('Raw html') | html %]" for="block_body" class="vat">[% loc('Block body') | html %]:</label>
                            <textarea name="block_body" id="block_body" rows="8" cols="48"></textarea><br />
                        <br />
                    <input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks?rnd=[% SESSION.RND %]" />
                    <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
            </td>
            <td class="lual w50">
                <label for="block_access_roles">[% loc('Access roles') | html %]:</label><br />
                [% INCLUDE common_roleslist_fmt.tpl 
                    t_selmultible=6, 
                    t_anyrole=1,
                    t_name='block_access_roles', 
                    t_selected={${SESSION.USR.role_id} => 1} 
                -%]
            </td>
        </tr>
        <tr class="windowbg">
            <td class="lmal" [% IF colspan %] colspan="[% colspan %]"[% END %]>
                <input type="submit" value="[% loc('Add block') | html %]" />
            </td>
        </tr>
    </table>
</form>
