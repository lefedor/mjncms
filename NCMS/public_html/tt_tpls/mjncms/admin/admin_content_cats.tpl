[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/cats.js') -%]
[% colspan=7 -%]
[% cat_ids=TT_CALLS.content_get_catrecord_tree('0') -%]
[% cat_res=TT_CALLS.content_get_catrecord(cat_ids, {
		#'disable_autotranslate' => 1, 
	}) -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/addcat?rnd=[% SESSION.RND %]" onClick="javascript:show_addcat_form();return false;">[+ [% loc('Add new') %]]</a></span>[% loc('Content categories management') -%]
        </td>
    </tr>
</table>
	[% IF cat_ids.size -%]
		<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_update_catseq();return false;[% ELSE %]return confirm('[% loc('Update categories sequence') %]?');[% END %]" name="update_cats_sequence" id="update_cats_sequence" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/setcatsequence" method="post" accept-charset="[% TT_VARS.html_charset %]">
			<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="cats_list_table">
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
				<tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
					<td class="w5">[% loc('Id') | html %]</td>
					<td class="lmal">[% loc('Name') | html %]</td>
					<td class="w5 hp" title="[% loc('is Active') | html %]">[% loc('isA') | html %]</td>
					<td class="w10">[% loc('Order') | html %] <input type="submit" value="[s]" class="hp f60 vam" title="save order"/></td>
					<td class="lmal w10">[% loc('Cname') | html %]</td>
					<td class="w5">[% loc('Level') | html %]</td>
					<td class="w20">[% loc('Actions') | html %]</td>
				</tr>
				[% prev_ord_lvl = 0 -%]
				[% order_seq={} -%]
				[% FOREACH cid=cat_ids -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					[% curr_lvl=cat_res.records.$cid.level -%]
					[% IF curr_lvl>=prev_ord_lvl -%]
						[% UNLESS order_seq.$curr_lvl -%]
							[% order_seq.$curr_lvl=0 -%]
						[% END -%]
					[% ELSIF curr_lvl<prev_ord_lvl -%]
						[% FOREACH key=order_seq.keys -%]
							[% IF key>curr_lvl -%]
								[% order_seq.$key=0 -%]
							[% END -%]
						[% END -%]
					[% END -%]
					[% order_seq.$curr_lvl=order_seq.$curr_lvl + 1 -%]
					<tr class="windowbg[% row_sw %]" id="catlist_tr_[% cid %]">
						<td class="cmal">
							[% cat_res.records.$cid.id -%]
						</td>
						<td class="lual">
							[% IF cat_res.records.$cid.level>1 -%]
								[% s='&nbsp;&nbsp;&nbsp;' -%]
								[% s.repeat((cat_res.records.$cid.level - 1)) %]<sup>L</sup>
							[% END -%]
							[% cat_res.records.$cid.name | html %]
						</td>
						<td class="cmal">
							[% IF cat_res.records.$cid.is_active -%]1[% ELSE %]0[% END %]
						</td>
						<td class="cmal">
							<input size="5" maxlength="5" type="text" value="[% order_seq.$curr_lvl %]" name="c_ord_[% cid %]" class="order_seq_inp"/>
						</td>
						<td class="lual">
							[% cat_res.records.$cid.cname | html -%]
						</td>
						<td class="cmal">
							[% curr_lvl -%]
						</td>
						<td class="cmal">
							<a onClick="javascript:show_editcat_dialog([% cid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/catedit/[% cid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit category') %]" title="[% loc('Edit category') %]" /></a>
							<a onClick="javascript:show_addcat_form([% cid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/addsubcat/[% cid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/subtree.gif" alt="[% loc('Add slave category') %]" title="[% loc('Add slave category') %]" /></a>
							<a onClick="javascript:show_managecattrans_form([% cid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/managecattrans/[% cid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/archive.gif" alt="[% loc('Manage translations') %]" title="[% loc('Manage translations') %]" /></a>
							<a onClick="javascript:show_setcatperm_form([% cid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/setcatperm/[% cid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/config_sm.gif" alt="[% loc('Set permissions') %]" title="[% loc('Set permissions') %]" /></a>
							<a onClick="javascript:return confirm('[% loc('Delete category') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/catdelete/[% cid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete category') %]" title="[% loc('Delete category') %]" /></a>
						</td>
					</tr>
					[% prev_ord_lvl=curr_lvl %]
				[% END #FOREACH cid=cat_ids -%]
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
			</table>
			<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/cats?rnd=[% SESSION.RND %]" />
		</form>
	[% ELSE #IF cat_ids.size -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
			<tr class="windowbg[% row_sw %]">
				<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					[% loc('No categories found') -%]
				</td>
			</tr>
		</table>
	[% END #IF cat_ids.size -%]
<script type="text/javascript" language="javascript">

	locale_cats.set('cat_lang', '[% loc('Lang') | html %]');
	locale_cats.set('cat_name', '[% loc('Name') | html %]');
	locale_cats.set('cat_name_lbl', '[% loc('Up to 32 chars') | html %]');
	locale_cats.set('cat_link', '[% loc('Link') | html %]');
	locale_cats.set('cat_extra', '[% loc('Extra data') | html %]');
    
    locale_cats.set('add_new_cat', '[% loc('Add new category') -%]');
    locale_cats.set('edit_cat', '[% loc('Edit category') -%]');
    locale_cats.set('delete_cat', '[% loc('Delete category') -%]');

    mjadm_url='[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]';
    
</script>
