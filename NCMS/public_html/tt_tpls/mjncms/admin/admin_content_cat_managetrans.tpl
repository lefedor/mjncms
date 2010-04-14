[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/cats.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
[% IF TT_VARS.cat_id && (matches = TT_VARS.cat_id.match('^\d+$')) -%]
	[% colspan=3 %]
	[% langs_res=SESSION.LOC.get_langs_list() -%]
	[% cat_id = TT_VARS.cat_id -%]
	[% res=TT_CALLS.content_get_catrecord(cat_id, {
		'disable_autotranslate' => 1, 
	}) -%]
	[%# res.q -%]
	[% UNLESS res.records.$cat_id && res.records.$cat_id.id -%]
		[% loc('Cat not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% transes=TT_CALLS.content_get_cattranses([cat_id]) -%]
	<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
		<tr class="titlebg">
			<td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
				[% loc('Manage translations for') | html %] &quot;[% res.records.$cat_id.name | html %]&quot;
			</td>
		</tr>
		<tr class="windowbg">
			<td class="windowbg lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
				<form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_save_cattrans_frm();return false;"[% END %] name="save_cattrans_frm" id="save_cattrans_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/addcattrans" method="post" accept-charset="[% TT_VARS.html_charset %]">
					<label for="t_cat_lang">[% loc('Translation lng') -%]:</label> 
						[% INCLUDE common_langlist_fmt.tpl t_name='cat_lang', t_id='t_cat_lang', t_selected={ ${SESSION.USR.member_sitelng} => 1 } -%]
							<br />
					<label for="t_cat_trans" title="[% loc('Up to 32 chars') | html %]">[% loc('Category name') | html %]: </label><input type="text" name="cat_trans" id="t_cat_trans" size="14" maxlength="32" /><br />
					<label for="t_cat_description" class="vat">[% loc('Category meta descr') | html %]:</label> <textarea name="cat_description" id="t_cat_description" rows="2" cols="24"></textarea><br />
					<label for="t_cat_keywords" class="vat">[% loc('Category meta keywords') | html %]:</label> <textarea name="cat_keywords" id="t_cat_keywords" rows="2" cols="24"></textarea><br />
					<br />
					 * [% loc('Meta Description Tag should contain Max of 25 keywords length or approx 150 characters') | html %].<br />
					 * [% loc('When you are writing the keywords in the Meta tags it should contain maximum of 30 keywords or 180 characters') | html %].<br />
					<input type="hidden" name="cat_id" value="[% cat_id %]" />
					<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/managecattrans/[% cat_id %]?rnd=[% SESSION.RND %]" />
					<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
					<input type="submit" value="[% loc('Add translation') | html %]" />
				</form>
			</td>
		</tr>
		[% IF transes.keys.size -%]
			<tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
				<td class="w5">[% loc('cat id') | html %]</td>
				<td class="lmal">[% loc('Lang') | html %] / [% loc('Name') | html %] / [% loc('Description') | html %] / [% loc('Keywords') | html %]</td>
				<td class="w20">[% loc('Actions') | html %]</td>
			</tr>
			[% FOREACH trs=transes.$cat_id.keys.sort -%]
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
				<tr class="windowbg[% row_sw %]">
					<td class="cmal">
							[% transes.$cat_id.$trs.cat_id -%]
					</td>
					<td class="lmal mwp">
						<form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_upd_cattrans_frm([% transes.$cat_id.$trs.cat_id -%]);return false;"[% END %] name="upd_cattrans_frm_[% transes.$cat_id.$trs.cat_id -%]" id="upd_cattrans_frm_[% transes.$cat_id.$trs.cat_id -%]" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/updcattrans" method="post" accept-charset="[% TT_VARS.html_charset %]">
							<input type="hidden" name="cat_id" value="[% transes.$cat_id.$trs.cat_id -%]" />
							<input type="hidden" name="cat_curtrans_lang" value="[% transes.$cat_id.$trs.lang -%]" />
							<table class="w100">
								<tr>
									<td class="lmal">
										[% INCLUDE common_langlist_fmt.tpl t_name='cat_lang', t_selected={ ${transes.$cat_id.$trs.lang} => 1 } -%]
									</td>
									<td>
										<label class="vat" for="cat_trans_[% $cat_id %]_[% $trs %]" title="[% loc('Translated name') | html %]">[% loc('Name') %]: </label>
										<input type="text" name="cat_trans" id="cat_trans_[% $cat_id %]_[% $trs %]" size="14" maxlength="32" value="[% transes.$cat_id.$trs.name | html %]"/>
									</td>
									<tdclass="lmal">
										<input type="submit" value="Update">
									</td>
								</tr>
								<tr>
									<td colspan="2" class="lmal">
										<label class="vat" for="t_cat_description_[% $cat_id %]_[% $trs %]" title="[% loc('Descr')  | html %]">[% loc('Descr') | html %]: </label>
										<textarea name="cat_description" id="t_cat_description_[% $cat_id %]_[% $trs %]" rows="2" cols="24">[% transes.$cat_id.$trs.descr | html %]</textarea>
									</td>
									<td class="lmal">
										<label class="vat" for="t_cat_keywords_[% $cat_id %]_[% $trs %]" title="[% loc('Keywords') | html %]">[% loc('Kwds') | html %]: </label>
										<textarea name="cat_keywords" id="t_cat_keywords_[% $cat_id %]_[% $trs %]" rows="2" cols="24">[% transes.$cat_id.$trs.keywords | html %]</textarea>
									</td>
								</tr>
							</table>
							<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/managecattrans/[% cat_id %]?rnd=[% SESSION.RND %]" />
							<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
						</form>
					</td>
					<td class="lmal">
							&nbsp; <a id="rmh_[% transes.$cat_id.$trs.cat_id -%]_[% transes.$cat_id.$trs.lang -%]" onClick="javascript:[% IF SESSION.REQ_ISAJAX %]show_delcattrans_dialog(this, '[% transes.$cat_id.$trs.cat_id -%]', '[% transes.$cat_id.$trs.lang -%]');return false;[% ELSE %]return confirm('[% loc('Delete translation') %]?')[% END %]" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/delcattrans/[% transes.$cat_id.$trs.cat_id -%]/[% transes.$cat_id.$trs.lang | html -%]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete translation') %]" title="[% loc('Delete translation') %]" /></a>
					</td>
				</tr>
			[% END #FOREACH trs= -%]
		[% END #IF transes.keys.size %]
	</table>
[% ELSE -%]
	[% loc('Wrong menu_id fmt') | html -%]
[% END #IF TT_VARS.menu_id.. -%]
