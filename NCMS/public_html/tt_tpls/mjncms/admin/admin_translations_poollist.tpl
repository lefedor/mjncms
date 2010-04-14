[% USE loc -%]
[% UNLESS SESSION.MEMC_UNTRANS_STRS -%]
	[% loc('Store untranslated string @ MEMC disabled') | html -%]
	[% RETURN -%]
[% END -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/translations.js') -%]
[% colspan=5 -%]
[% res=TT_CALLS.translations_poollist_get() -%]
[% IF res.message -%]
	[% loc('Permissions list receiving fail') | html -%]:[% res.message | html -%]
	[% RETURN -%]
[% END -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('UnTranslated strings management') -%]
        </td>
    </tr>
</table>
	[% IF res.keys.size -%]
			<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="awproles_list_table">
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
				<tr class="catbg3 nwp b cmal">
					<td class="w10 cmal">[% loc('LangID') | html %]</td>
					<td class="lmal">[% loc('Lang name / Path') | html %]</td>
					<td class="cmal w20">[% loc('Strings count') | html %]</td>
					<td class="w15 cmal">[% loc('Define') | html %]</td>
				</tr>
				[% FOREACH lang=res.keys.sort -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					<tr class="windowbg[% row_sw %]">
						<td class="cmal">
							[% lang | html -%]
						</td>
						<td class="lmal">
							[% SESSION.LOC.get_langs_list().${lang}.name | html -%]<br />
							[% loc('Locale') %]: [% (SESSION.LOC.get_langs_list().${lang}.locale || SESSION.SITE_LOCALE) | html -%]
						</td>
						<td class="lmal">
							[% res.${lang}.size -%]
						</td>
						<td class="cmal">
							<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/translations/set_strings/[% lang | html -%]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Set strings') %]" title="[% loc('Set strings') %]" /></a>
							<a onClick="javascript:return confirm('[% loc('Clear cache') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/translations/clear_cache/[% lang | html %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Clear lang cache') %]" title="[% loc('Clear lang cache') %]" /></a>
						</td>
					</tr>
				[% END #FOREACH lang=res.keys.sort -%]
			</table>
	[% ELSE #IF res.keys.size -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
			<tr class="windowbg">
				<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					[% loc('No untranslated strings found in memc cache') -%]
				</td>
			</tr>
		</table>
	[% END #IF res.keys.size -%]
<script type="text/javascript" language="javascript">

	//locale_translations.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
