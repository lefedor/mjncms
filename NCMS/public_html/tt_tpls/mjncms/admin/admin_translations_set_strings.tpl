[% USE loc -%]
[% UNLESS SESSION.MEMC_UNTRANS_STRS -%]
	[% loc('Store untranslated string @ MEMC disabled') | html -%]
	[% RETURN -%]
[% END -%]
[% UNLESS TT_VARS.lang && (matches = TT_VARS.lang.match('^\w{2,4}$')) -%]
	[% loc('Lang variable is not set') | html -%]
	[% RETURN -%]
[% END -%]
[% USE bytestream -%]
[% lang=TT_VARS.lang -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/translations.js') %][% END -%]
[% colspan=2 -%]
[% res=TT_CALLS.translations_poollist_get() -%]
[% IF res.message || !res.${lang} -%]
	[% loc('Permissions list receiving fail') | html -%]:[% res.message | html -%]
	[% RETURN -%]
[% END -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Set strings translations for language') -%]: &quot;[% SESSION.LOC.get_langs_list().${lang}.name | html -%]&quot;
        </td>
    </tr>
</table>
	[% IF res.${lang} -%]
		<form onSubmit="javascript:return confirm('[% loc('Save translations') %]?')" name="save_transes_frm" id="save_transes_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/translations/set_strings/[% lang %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
			<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="awproles_list_table">
				<tr class="catbg3 nwp b cmal">
					<td class="lmal w50">[% loc('String') | html %]</td>
					<td class="lmal">[% loc('Translation') | html %]</td>
				</tr>
				[% FOREACH string=res.${lang}.values.sort -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					<tr class="windowbg[% row_sw %]">
						<td class="cmal">
							<textarea name="src_[% bytestream(string, 'md5_sum') | html %]" cols="40" rows="3" readonly="readonly">[% string | html %]</textarea>
						</td>
						<td class="lmal">
							<textarea name="trans_[% bytestream(string, 'md5_sum') | html %]" cols="40" rows="3"></textarea>
						</td>
					</tr>
				[% END #FOREACH string=res.${lang}.values.sort -%]
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
				<tr>
					<td [% IF colspan %] colspan="[% colspan %]"[% END %] class="rmal windowbg[% row_sw %]">
						<input type="submit" value="[% loc('Set translated strings') | html %]" />
					</td>
				</tr>
			</table>
			<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/translations?rnd=[% SESSION.RND %]" />
			<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
		</form>
	[% ELSE #IF res.${lang} -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
			<tr class="windowbg">
				<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					[% loc('Untranslated strings for selected language not found') -%]
				</td>
			</tr>
		</table>
	[% END #IF res.keys.size -%]
<script type="text/javascript" language="javascript">

	//locale_translations.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
