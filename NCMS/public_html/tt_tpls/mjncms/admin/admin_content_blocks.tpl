[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/blocks.js') -%]
[% colspan=6 -%]
[% res=TT_CALLS.content_get_blocks({
    'page' => SESSION.REQ.param('page'), 
    'skip_access_roles_rule' => 1,
}) -%]
[% IF res.message -%]
    [% loc('Blocks list receiving fail') | html -%]:[% res.message | html -%]
    [% RETURN -%]
[% END -%]
[%# res.q -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="menus_list_table">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/add?rnd=[% SESSION.RND %]">[+ [% loc('Add new') %]]</a></span>[% loc('Content blocks management') -%]
        </td>
    </tr>
</table>
    [% IF res.blocks.size -%]
            <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
                    <td class="w5">[% loc('Id') | html %]</td>
                    <td class="w15">[% loc('Alias') | html %]</td>
                    <td class="lmal">[% loc('Header') | html %]</td>
                    <td class="w15">[% loc('Author') | html %]</td>
                    <td class="w5 hp" title="[% loc('is Active') | html %]">[% loc('isA') | html %]</td>
                    <td class="w10">[% loc('Actions') | html %]</td>
                </tr>
                [% IF res.pages.count>1 -%]
                    <tr>
                        <td class="titlebg"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                            [% INCLUDE common_pager_simple.tpl pages=res.pages %]
                        </td>
                    </tr>
                [% END #IF res.pages.count>1 -%]
                [% FOREACH block=res.blocks -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                    <tr class="windowbg[% row_sw %]" id="pagelist_tr_[% cid %]">
                        <td class="cmal">
                            [% block.block_id -%]
                        </td>
                        <td class="lmal">
                            [% block.alias -%]
                        </td>
                        <td class="lual">
                            [% block.header | html -%]
                        </td>
                        <td class="cmal">
                            [% block.creator | html -%]
                        </td>
                        <td class="cmal">
                            [% IF block.is_active %]1[% ELSE %]0[% END %]
                        </td>
                        <td class="cmal">
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/edit/[% block.block_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit block') %]" title="[% loc('Edit block') %]" /></a>
                            [% IF block.lang %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/transes/[% block.block_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/archive.gif" alt="[% loc('Manage block translations') %]" title="[% loc('Manage block translations') %]" /></a>[% END -%]
                            <a onClick="javascript:return confirm('[% loc('Delete block') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/delete/[% block.block_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete block') %]" title="[% loc('Delete block') %]" /></a>
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
    [% ELSE #IF res.blocks.size -%]
        <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
            <tr class="windowbg[% row_sw %]">
                <td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                    [% loc('No blocks found') | html -%]
                </td>
            </tr>
        </table>
    [% END #IF res.blocks.size -%]
<script type="text/javascript" language="javascript">

    //locale_pages.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
