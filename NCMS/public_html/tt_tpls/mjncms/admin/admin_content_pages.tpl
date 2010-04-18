[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/pages.js') -%]
[% colspan=7 -%]
[% pages=TT_CALLS.content_get_pagerecord({
    page => SESSION.REQ.param('page'), #not page_id, for listing 1..n
}) -%]
[% IF pages.message -%]
    [% loc('Pages list receiving fail') | html -%]:[% pages.message | html -%]
    [% RETURN -%]
[% END -%]
[%# pages.q -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="menus_list_table">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/addpage?rnd=[% SESSION.RND %]">[+ [% loc('Add new') %]]</a></span>[% loc('Content pages management') -%]
        </td>
    </tr>
</table>
    [% IF pages.pages_res.size -%]
            <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
                [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                <tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
                    <td class="w5">[% loc('Id') | html %]</td>
                    <td class="w15">[% loc('Slug') | html %]</td>
                    <td class="lmal">[% loc('Header') | html %]</td>
                    <td class="w20">[% loc('Category') | html %]</td>
                    <td class="w15">[% loc('Author') | html %]</td>
                    <td class="w5 hp" title="[% loc('is Published') | html %]">[% loc('isP') | html %]/[% loc('Date') | html %]</td>
                    <td class="w10">[% loc('Actions') | html %]</td>
                </tr>
                [% IF pages.pages.count>1 -%]
                    <tr>
                        <td class="titlebg"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                            [% INCLUDE common_pager_simple.tpl pages=pages.pages %]
                        </td>
                    </tr>
                [% END #IF pages.pages.count>1 -%]
                [% FOREACH page=pages.pages_res -%]
                    [% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
                    <tr class="windowbg[% row_sw %]" id="pagelist_tr_[% page.page_id -%]">
                        <td class="cmal">
                            [% page.page_id -%]
                        </td>
                        <td class="lmal">
                            [% page.slug -%]
                        </td>
                        <td class="lual">
                            [% page.header | html -%]
                        </td>
                        <td class="cmal">
                            [% IF page.cat_id -%]
                                [% page.cat_name | html -%]
                            [% ELSE -%]
                                [% loc('No category') | html %]
                            [% END -%]
                        </td>
                        <td class="cmal">
                            [% page.author | html -%]
                        </td>
                        <td class="cmal">
                            [% IF page.is_published %]1[% ELSE %]0[% END %]
                        </td>
                        <td class="cmal">
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/editpage/[% page.page_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit page') %]" title="[% loc('Edit page') %]" /></a>
                            <a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/page_managetrans/[% page.page_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/archive.gif" alt="[% loc('Manage page translations') %]" title="[% loc('Manage page translations') %]" /></a>
                            <a onClick="javascript:return confirm('[% loc('Delete page') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/delpage/[% page.page_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete page') %]" title="[% loc('Delete page') %]" /></a>
                        </td>
                    </tr>
                [% END #FOREACH page=pages.pages_res -%]
                [% IF pages.pages.count>1 -%]
                    <tr>
                        <td class="titlebg"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                            [% INCLUDE common_pager_simple.tpl pages=pages.pages %]
                        </td>
                    </tr>
                [% END #IF pages.pages.count>1 -%]
            </table>
    [% ELSE #IF pages.pages_res.size -%]
        <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
            <tr class="windowbg[% row_sw %]">
                <td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
                    [% loc('No pages found') | html -%]
                </td>
            </tr>
        </table>
    [% END #IF pages.pages_res.size -%]
<script type="text/javascript" language="javascript">

    //locale_pages.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
