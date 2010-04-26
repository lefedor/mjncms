[% USE loc -%]
[% USE bytestream -%]
[% colspan=2 -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/blocks.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
[% IF 
    TT_VARS.block_id && (matches = TT_VARS.block_id.match('^\d+$')) &&
    TT_VARS.lang && (matches = TT_VARS.lang.match('^\w{2,4}$')) 
-%]
    [% block_id = TT_VARS.block_id -%]
    [% lang = TT_VARS.lang -%]
    [% res=TT_CALLS.content_get_blocks({
        'block_id' => block_id, 
        'mode' => 'as_hash', 
        'disable_autotranslate' => 1, 
        'get_access_roles' => 1,
        'get_transes' => 1, 
        'skip_access_roles_rule' => 1,
        
    }) -%]
    [%# res.q -%]
    [% UNLESS 
        res.blocks.$block_id && 
        res.blocks.$block_id.block_id &&
        res.blocks.$block_id.is_writable
    -%]
        [% loc('Block not found or no access') | html -%]
        [% RETURN -%]
    [% END -%]
    [% UNLESS res.blocks.${block_id}.lang -%]
        [% loc('You\'re trying translate multi-lang block') | html -%]
        [% RETURN -%]
    [% END -%]
    [% UNLESS res.transes.${block_id}.${lang} -%]
        [% loc('Page trans lang not found or no access') | html -%]
        [% RETURN -%]
    [% END -%]
    [% block=res.blocks.$block_id -%]
    [% UNLESS block.use_access_roles  -%]
        [% ar={'any'=>1} -%]
    [% ELSE -%]
        [% ar=res.blocks_access_roles.$block_id -%]
    [% END -%]
    [% trans = res.transes.${block_id}.${lang} -%]
[% ELSE -%]
    [% loc('Block id is not \d+ or lang is wrong') | html -%]
    [% RETURN -%]
[% END #IF TT_VARS.block_id -%]
<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_edit_block_trans_subm();return false;[% ELSE %]return confirm('[% loc('Edit block translation') | html %]?');[% END %]" name="edit_block_translation_frm" id="edit_block_translation_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/transes/[% block_id %]/[% lang | html %]/edit" method="post" accept-charset="[% TT_VARS.html_charset %]">
    <table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
        <tr class="titlebg">
            <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
                [% loc('Edit block translation') | html -%]
            </td>
        </tr>
        <tr class="windowbg">
            <td class="windowbg lual" style="padding: 7px;">
                    <label for="block_alias" title="[% loc('Up to 32 chars, to call from template by alias, not by id') | html %]">[% loc('Block alias') | html %]: </label>
                        <input disabled="disabled" readonly="readonly" type="text" name="block_alias" id="block_alias" size="14" maxlength="32" value="[% block.alias | html %]"/><br />
                    <input disabled="disabled" readonly="readonly" type="checkbox" name="block_isactive" id="block_isactive" value="1" class="vam"[% IF block.is_active %] checked="checked"[% END %]/>
                        <label for="block_isactive">[% loc('Is active') | html %]</label><br />
                    
                    <label for="block_lang">[% loc('Origial lng') | html %]:</label> 
                    [% SESSION.LOC.get_langs_list().${block.lang}.name | html -%]
                    <input type="hidden" value="[% trans.lang | html %]" name="old_lang" />
                    <br />
                    <label for="block_lang">[% loc('Translation lng') | html %]:</label> 
                        [% INCLUDE common_langlist_fmt.tpl 
                            t_name='block_lang', 
                            t_anylang=1,
                            t_selected={ ${trans.lang} => 1 } 
                        -%]
                        <br /><br />
                    <label for="block_header" title="[% loc('Up to 64 chars') | html %]">[% loc('Block header') | html %]: </label>
                        <input type="text" name="block_header" id="block_header" size="14" maxlength="64" value="[% trans.header | html %]" />
                    <input disabled="disabled" readonly="readonly" type="checkbox" name="block_show_header" id="block_show_header" value="1" class="vam"[% IF block.show_header %] checked="checked"[% END %]/>
                        <label for="block_show_header" title="[% loc('Show header') | html %]">[% loc('Show') | html %]</label><br />
                        <label title="[% loc('Raw html') | html %]" for="block_body" class="vat">[% loc('Block body') | html %]:</label>
                            <textarea name="block_body" id="block_body" rows="8" cols="48">[% trans.body | html %]</textarea><br />
                        <br />
                    <input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/blocks/transes/[% block_id %]?rnd=[% SESSION.RND %]" />
                    <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
            </td>
            <td class="lual w50">
                <label for="block_access_roles">[% loc('Access roles') | html %]:</label><br />
                [% INCLUDE common_roleslist_fmt.tpl 
                    t_selmultible=6, 
                    t_anyrole=1,
                    t_name='block_access_roles', 
                    t_selected=ar, 
                    t_disabled=1
                -%]
            </td>
        </tr>
        <tr class="windowbg">
            <td class="lmal" [% IF colspan %] colspan="[% colspan %]"[% END %]>
                <input type="submit" value="[% loc('Edit block translation') | html %]" />
            </td>
        </tr>
    </table>
</form>
