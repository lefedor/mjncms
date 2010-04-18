[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/cats.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
[% langs_res=SESSION.LOC.get_langs_list() -%]
[% IF TT_VARS.cat_id && (matches = TT_VARS.cat_id.match('^\d+$')) -%]
	[% cat_id = TT_VARS.cat_id -%]
	[% res=TT_CALLS.content_get_catrecord(cat_id, {
		'disable_autotranslate' => 1, 
	}) -%]
	[%# res.q -%]
	[% UNLESS res.records.$cat_id && res.records.$cat_id.id -%]
		[% loc('Parent category id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
[% ELSE -%]
	[% loc('category id is not \d+') | html -%]
	[% RETURN -%]
[% END #IF TT_VARS.cat_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Edit category data') %] &quot;[% res.records.$cat_id.name | html %]&quot;
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_edit_cat_subm();return false;[% ELSE %]return confirm('[% loc('Edit category data') %]?');[% END %]" name="save_edited_cat_frm" id="save_edited_cat_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/editcat" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<label for="e_cat_cname" title="[% loc('Up to 16 chars, to call from template by cname, not by id, for url path') | html %]">[% loc('Category cname / Slug') -%]: </label><input type="text" name="cat_cname" id="e_cat_cname" size="14" maxlength="16" value="[% res.records.$cat_id.cname | html %]" /><br />
				<label for="e_cat_name" title="[% loc('Up to 32 chars') -%]">[% loc('Category name') | html %]: </label><input type="text" name="cat_name" id="e_cat_name" size="14" maxlength="32" value="[% res.records.$cat_id.name | html %]"/>
				[% lang_key=res.records.$cat_id.lang -%]
					<i>([% loc('Category default lng') -%]: [% loc(langs_res.$lang_key.name) | html %])</i><br />
				<input type="checkbox" name="cat_isactive" id="e_cat_isactive" value="1" class="vam"[% IF res.records.$cat_id.is_active %] checked="checked"[% END %]/><label for="e_cat_isactive">[% loc('Is active') | html %].</label><br />
					<br /><br />
					<label for="e_cat_description" class="vat">[% loc('Category meta descr') | html %]:</label> <textarea name="cat_description" id="e_cat_description" rows="2" cols="24">[% res.records.$cat_id.descr | html %]</textarea><br />
					<label for="e_cat_keywords" class="vat">[% loc('Category meta keywords') | html %]:</label> <textarea name="cat_keywords" id="e_cat_keywords" rows="2" cols="24">[% res.records.$cat_id.keywords | html %]</textarea><br />
					<br />
					 * [% loc('Meta Description Tag should contain Max of 25 keywords length or approx 150 characters') %].<br />
					 * [% loc('When you are writing the keywords in the Meta tags it should contain maximum of 30 keywords or 180 characters') %].
					
					<br /><br />
				<input type="hidden" name="cat_id" value="[% cat_id %]" />
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/cats?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
				<input type="submit" value="[% loc('Edit category data') | html %]" />
			</form>

		</td>
	</tr>
</table>
