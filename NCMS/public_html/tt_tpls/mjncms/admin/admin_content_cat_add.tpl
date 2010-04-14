[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/cats.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
[% langs_res=SESSION.LOC.get_langs_list() -%]
[% IF TT_VARS.parent_cat_id && (matches = TT_VARS.parent_cat_id.match('^\d+$')) -%]
	[% parent_cat_id = TT_VARS.parent_cat_id -%]
	[% res=TT_CALLS.content_get_catrecord(parent_cat_id, {
		#'disable_autotranslate' => 1, 
	}) -%]
	[%# res.q -%]
	[% UNLESS res.records.$parent_cat_id && res.records.$parent_cat_id.id -%]
		[% loc('Parent category id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
[% ELSE -%]
	[% TT_VARS.delete('parent_cat_id') -%]
[% END #IF TT_VARS.parent_cat_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Create an new category') | html %][% IF parent_cat_id %][% IF SESSION.REQ_ISAJAX %]<br />[% END -%] [[% loc('Slave for') | html %]: &quot;[% res.records.$parent_cat_id.name | html %]&quot;][% END -%]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_add_cat_subm();return false;[% ELSE %]return confirm('[% loc('Add category') | html %]?');[% END %]" name="save_new_cat_frm" id="save_new_cat_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/addsubcat" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<label for="cat_cname" title="[% loc('Up to 16 chars, to call from template by cname, not by id, for url path') | html %]">[% loc('Category cname / Slug') | html %]: </label><input type="text" name="cat_cname" id="cat_cname" size="14" maxlength="16" /><br />
				<label for="cat_name" title="[% loc('Up to 32 chars') | html %]">[% loc('Category name') | html %]: </label><input type="text" name="cat_name" id="cat_name" size="14" maxlength="32" /><br />
				<input type="checkbox" name="cat_isactive" id="cat_isactive" value="1" class="vam" checked="checked"/><label for="cat_isactive">[% loc('Is active') | html %].</label><br />
				<label for="cat_lang">[% loc('Category default lng') | html %]:</label> 
					[% selected_lang=SESSION.USR.member_sitelng -%]
					[% IF parent_cat_id %][% selected_lang=res.records.$parent_cat_id.lang %][% END -%]
					[% INCLUDE common_langlist_fmt.tpl t_name='cat_lang', t_selected={ ${selected_lang} => 1 } -%]
					<br /><br />
					<label for="cat_description" class="vat">[% loc('Category meta descr') | html %]:</label> <textarea name="cat_description" id="cat_description" rows="2" cols="24"></textarea><br />
					<label for="cat_keywords" class="vat">[% loc('Category meta keywords') | html %]:</label> <textarea name="cat_keywords" id="cat_keywords" rows="2" cols="24"></textarea><br />
					<br />
					 * [% loc('Meta Description Tag should contain Max of 25 keywords length or approx 150 characters') | html %].<br />
					 * [% loc('When you are writing the keywords in the Meta tags it should contain maximum of 30 keywords or 180 characters') | html %].
					
					<br /><br />
				[% IF parent_cat_id %]<input type="hidden" name="parent_cat_id" value="[% parent_cat_id %]" />[% END -%]
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/cats?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
				<input type="submit" value="[% loc('Create category') | html %]" />
			</form>

		</td>
	</tr>
</table>
