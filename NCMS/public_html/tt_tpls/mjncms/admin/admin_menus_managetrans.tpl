[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/menus.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
[% IF TT_VARS.menu_id && (matches = TT_VARS.menu_id.match('^\d+$')) -%]
    [% colspan=3 %]
    [% langs_res=SESSION.LOC.get_langs_list() -%]
    [% menu_id = TT_VARS.menu_id -%]
    [% res=TT_CALLS.menus_get_record(menu_id, {
        'disable_autotranslate' => 1, 
    }) -%]
    [%# res.q -%]
    [% UNLESS res.records.$menu_id && res.records.$menu_id.id -%]
        [% loc('Menu not found or no access') | html -%]
        [% RETURN -%]
    [% END -%]
    [% transes=TT_CALLS.menus_get_transes([menu_id]) -%]
    <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
        <tr class="titlebg">
            <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
                [% loc('Manage translations for') | html %] &quot;[% res.records.$menu_id.text | html %]&quot;
            </td>
        </tr>
        <tr class="windowbg">
            <td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                <form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_save_menutrans_frm();return false;"[% END %] name="save_menutrans_frm" id="save_menutrans_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/addtrans" method="post" accept-charset="[% TT_VARS.html_charset %]">
                    <label for="t_menu_lang">[% loc('Translation lng') -%]:</label> 
                        [% INCLUDE common_langlist_fmt.tpl t_name='menu_lang', t_id='t_menu_lang', t_selected={ ${SESSION.USR.member_sitelng} => 1 } -%]
                            <br />
                    <label for="t_menu_trans" title="[% loc('Up to 32 chars') -%]">[% loc('Menu name') -%]: </label><input type="text" name="menu_trans" id="t_menu_trans" size="14" maxlength="32" />
                    <label for="t_menu_altlink" title="[% loc('Alternative link [optional]') -%]">[% loc('Alternative link (opt)') -%]: </label><input type="text" name="menu_altlink" id="t_menu_altlink" size="20" /><br />
                    <input type="hidden" name="menu_id" value="[% menu_id %]" />
                    <input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/managetrans/[% menu_id %]?rnd=[% SESSION.RND %]" />
                    <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
                    <input type="submit" value="[% loc('Add translation') %]" />
                </form>
            </td>
        </tr>
        [% IF transes.keys.size -%]
            <tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
                <td class="w5">[% loc('menu id') | html %]</td>
                <td class="lmal">[% loc('Lang') | html %] / [% loc('Name') | html %] / [% loc('Alt href') | html %]</td>
                <td class="w20">[% loc('Actions') | html %]</td>
            </tr>
            [% FOREACH trs=transes.$menu_id.keys -%]
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="windowbg[% row_sw %]">
                    <td class="cmal">
                            [% transes.$menu_id.$trs.menu_id -%]
                    </td>
                    <td class="lmal nwp">
                        <form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_upd_menutrans_frm([% transes.$menu_id.$trs.menu_id -%]);return false;"[% END %] name="upd_menutrans_frm_[% transes.$menu_id.$trs.menu_id -%]" id="upd_menutrans_frm_[% transes.$menu_id.$trs.menu_id -%]" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/updtrans" method="post" accept-charset="[% TT_VARS.html_charset %]">
                            <input type="hidden" name="menu_id" value="[% transes.$menu_id.$trs.menu_id -%]" />
                            <input type="hidden" name="menu_curtrans_lang" value="[% transes.$menu_id.$trs.lang %]" />
                            [% INCLUDE common_langlist_fmt.tpl t_name='menu_lang', t_selected={ ${transes.$menu_id.$trs.lang} => 1 } -%]<br />
                            [% loc('Name') | html %]: <input type="text" name="menu_trans" id="menu_trans" size="14" maxlength="32" value="[% transes.$menu_id.$trs.text | html -%]"/>
                            [% loc('Link') | html %]: <input type="text" name="menu_altlink" id="menu_altlink" size="20" value="[% transes.$menu_id.$trs.link | html -%]" /><br />

                            <input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/managetrans/[% menu_id %]?rnd=[% SESSION.RND %]" />
                            <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
                            <input type="submit" value="Update">
                        </form>
                    </td>
                    <td class="lmal">
                            &nbsp; <a id="rmh_[% transes.$menu_id.$trs.menu_id %]_[% transes.$menu_id.$trs.lang %]" onClick="javascript:[% IF SESSION.REQ_ISAJAX %]show_deltrans_dialog(this, '[% transes.$menu_id.$trs.menu_id %]', '[% transes.$menu_id.$trs.lang %]');return false;[% ELSE %]return confirm('[% loc('Delete translation') %]?')[% END %]" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/deltrans/[% transes.$menu_id.$trs.menu_id %]/[% transes.$menu_id.$trs.lang | html %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete translation') %]" title="[% loc('Delete translation') %]" /></a>
                    </td>
                </tr>
            [% END #FOREACH trs= -%]
        [% END #IF transes.keys.size %]
    </table>
[% ELSE -%]
    [% loc('Wrong menu_id fmt') | html -%]
[% END #IF TT_VARS.menu_id.. -%]
