[% USE loc -%]
[% USE bytestream -%]
[% IF TT_VARS.page_id && (matches = TT_VARS.page_id.match('^\d+$')) -%]
    [% page_id=TT_VARS.page_id -%]
    [% page_transes=TT_CALLS.pages_get_transes({'page_id' => page_id, }) -%]
    [%# page_transes.q -%]
    [% IF page_transes.message -%]
        [% loc('Page transes list receiving fail') | html -%]:[% page_transes.message | html -%]
        [% RETURN -%]
    [% END -%]
[% END -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/pages.js') -%]
[% colspan=3 -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="menus_list_table">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/page_managetrans/[% page_id %]/add?rnd=[% SESSION.RND %]">[+ [% loc('Add new') %]]</a></span>[% loc('Page translations management') | html -%]
        </td>
    </tr>
</table>
    [% IF page_transes.transes.$page_id.keys.size -%]
            <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
                    <td class="w15">[% loc('Lang') | html %]</td>
                    <td class="lmal">[% loc('Header') | html %]</td>
                    <td class="w10">[% loc('Actions') | html %]</td>
                </tr>
                [% FOREACH pt_lang=page_transes.transes.$page_id.keys -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                    <tr class="windowbg[% row_sw %]" id="pagetrans_tr_[% page_id %]_[% pt_lang %]">
                        <td class="cmal">
                            [% SESSION.LOC.get_langs_list().${pt_lang}.name | html -%]
                        </td>
                        <td class="lual">
                            [% page_transes.transes.$page_id.$pt_lang.header | html -%]
                        </td>
                        <td class="cmal">
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/page_managetrans/[% page_id %]/[% pt_lang | html %]/edit?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit page translation') %]" title="[% loc('Edit page translation') %]" /></a>
                            <a onClick="javascript:return confirm('[% loc('Delete translation') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/page_managetrans/[% page_id %]/[% pt_lang | html %]/delete?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete translation') %]" title="[% loc('Delete translation') %]" /></a>
                        </td>
                    </tr>
                [% END #FOREACH pt=page_transes.transes -%]
            </table>
    [% ELSE #IF page_transes.transes.$page_id.keys.size -%]
        <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
            <tr class="windowbg[% row_sw %]">
                <td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                    [% loc('No translations found') -%]
                </td>
            </tr>
        </table>
    [% END #IF page_transes.transes.$page_id.keys.size -%]
<script type="text/javascript" language="javascript">

    //locale_pages.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
