[% USE loc -%]
[% USE bytestream -%]
<table width="100%" cellpadding="4" cellspacing="1" border="0" class="bordercolor">
    <tr>
        <td class="catbg">[% loc('Content') %]</td>
    </tr>
    <tr class="windowbg2">
        <td class="smalltext" style="line-height: 1.3; padding-bottom: 3ex;">
            [% IF tt_action=='menus' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus?rnd=[% SESSION.RND %]">[% loc('Menus') %]</a>[% IF tt_action=='menus' %]</b>[% END %]<br />
            [% IF tt_action=='content_cats' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/cats?rnd=[% SESSION.RND %]">[% loc('Categories') %]</a>[% IF tt_action=='content_cats' %]</b>[% END %]<br />
            [% IF tt_action=='content_pages' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/pages?rnd=[% SESSION.RND %]">[% loc('Pages') %]</a>[% IF tt_action=='content_pages' %]</b>[% END %]<br />
            [% IF tt_action=='content_blocks' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks?rnd=[% SESSION.RND %]">[% loc('Blocks') %]</a>[% IF tt_action=='content_blocks' %]</b>[% END %]<br />
            <!-- [% IF tt_action=='content_comment' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/comments?rnd=[% SESSION.RND %]">[% loc('Comments') %]</a>[% IF tt_action=='content_comments' %]</b>[% END %]<br /> -->
            [% IF tt_action=='content_filemanager' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/filemanager?rnd=[% SESSION.RND %]">[% loc('File Manager') %]</a>[% IF tt_action=='content_filemanager' %]</b>[% END %]<br />
            [% IF tt_action=='content_short_urls' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/short_urls?rnd=[% SESSION.RND %]">[% loc('Short Urls') %]</a>[% IF tt_action=='content_short_urls' %]</b>[% END %]<br />
        </td>
    </tr>
    <tr>
        <td class="catbg">[% loc('CMS Settings') %]</td>
    </tr>
    <tr class="windowbg2">
        <td class="smalltext" style="line-height: 1.3; padding-bottom: 3ex;">
            [% IF tt_action=='translations_poollist' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/translations?rnd=[% SESSION.RND %]">[% loc('Translations pool') %]</a>[% IF tt_action=='translations_poollist' %]</b>[% END %]<br />
            <!-- [% IF tt_action=='sysvars_list' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/sysvars?rnd=[% SESSION.RND %]">[% loc('System variables') %]</a>[% IF tt_action=='sysvars_list' %]</b>[% END %]<br /> -->
        </td>
    </tr>
    <tr>
        <td class="catbg">[% loc('Users') %]</td>
    </tr>
    <tr class="windowbg2">
        <td class="smalltext" style="line-height: 1.3; padding-bottom: 3ex;">
            [% IF tt_action=='permissions' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/permissions?rnd=[% SESSION.RND %]">[% loc('Permission types') %]</a>[% IF tt_action=='permissions' %]</b>[% END %]<br />
            [% IF tt_action=='awproles' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles?rnd=[% SESSION.RND %]">[% loc('AWPs/Roles') %]</a>[% IF tt_action=='awproles' %]</b>[% END %]<br />
            [% IF tt_action=='users' %]<b>[% END %]<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/users?rnd=[% SESSION.RND %]">[% loc('Users') %]</a>[% IF tt_action=='users' %]</b>[% END %]<br />
        </td>
    </tr>
</table>
