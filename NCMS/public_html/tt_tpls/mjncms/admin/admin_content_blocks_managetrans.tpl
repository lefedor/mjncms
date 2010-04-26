[% USE loc -%]
[% USE bytestream -%]
[% IF TT_VARS.block_id && (matches = TT_VARS.block_id.match('^\d+$')) -%]
    [% block_id=TT_VARS.block_id -%]
    [% block_transes=TT_CALLS.blocks_get_transes({'block_id' => block_id, }) -%]
    [%# block_transes.q -%]
    [% IF block_transes.message -%]
        [% loc('Block transes list receiving fail') | html -%]:[% block_transes.message | html -%]
        [% RETURN -%]
    [% END -%]
[% END -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/pages.js') -%]
[% colspan=3 -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="menus_list_table">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/transes/[% block_id %]/add?rnd=[% SESSION.RND %]">[+ [% loc('Add new') %]]</a></span>[% loc('Block translations management') | html -%]
        </td>
    </tr>
</table>
    [% IF block_transes.transes.${block_id}.keys.size -%]
            <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
                    <td class="w15">[% loc('Lang') | html %]</td>
                    <td class="lmal">[% loc('Header') | html %]</td>
                    <td class="w10">[% loc('Actions') | html %]</td>
                </tr>
                [% FOREACH bk_lang=block_transes.transes.${block_id}.keys -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                    <tr class="windowbg[% row_sw %]" id="blocktrans_tr_[% block_id %]_[% bk_lang %]">
                        <td class="cmal">
                            [% SESSION.LOC.get_langs_list().${bk_lang}.name | html -%]
                        </td>
                        <td class="lual">
                            [% block_transes.transes.$block_id.${bk_lang}.header | html -%]
                        </td>
                        <td class="cmal">
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/transes/[% block_id %]/[% bk_lang | html %]/edit?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit block translation') %]" title="[% loc('Edit block translation') %]" /></a>
                            <a onClick="javascript:return confirm('[% loc('Delete translation') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/transes/[% block_id %]/[% bk_lang | html %]/delete?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete translation') %]" title="[% loc('Delete translation') %]" /></a>
                        </td>
                    </tr>
                [% END #FOREACH bk_lang=block_transes.transes.${block_id}.keys -%]
            </table>
    [% ELSE #IF block_transes.transes.$block_id.keys.size -%]
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
