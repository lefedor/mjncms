[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX -%]
    [% TT_VARS.CSS.push(SESSION.THEME_URLPATH _ '/_static/css/main.css10') -%]
    [% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/mootools.js10') -%]
    [% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/mootools-more.js15') -%]
    [%# TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/mootools-local.js25') -%]
[% END -%]
[% tt_controller=TT_VARS.tt_controller -%]
[% tt_action=TT_VARS.tt_action -%]
[%# -%]
[% IF !tt_controller || !tt_action -%]
    [% tt_controller='content' -%]
    [% tt_action='index' -%]
[% END #IF !tt_controller || !tt_action -%]
[%# -%]
[% UNLESS SESSION.REQ_ISAJAX -%]
    [% TT_CALLS.register_tt_call('menus_site_lib_read', 'menus_get_record') -%]
    [% TT_CALLS.register_tt_call('menus_site_lib_read', 'menus_get_record_tree') -%]
    <script type="text/javascript" language="javascript">
        if(!mj_sys_vals){
            var mj_sys_vals = new Hash();
        }
        
        mj_sys_vals.set('mjadm_url', '[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]');
        mj_sys_vals.set('theme_url', '[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]');
        MooTools.lang.setLanguage('ru-RU-unicode');
        MooTools.lang.set('ru-RU-unicode', 'cascade', ['ru-RU-unicode', 'en-US']);
    </script>
        [% IF TT_VARS.MSG -%]
            <table style='width:100%;border:2px solid green;margin-top:4px;margin-bottom:4px;' cellpadding='0' cellspacing='0'>
                <tr>
                    <td style='vertical-align:middle;text-align:center;background-color:#c1e5b0;height:60px;'>
                        <b>[% loc(TT_VARS.MSG) | html %]</b>
                    </td>
                </tr>
            </table>
            <br />
        [% END -%]
[% ELSE #UNLESS SESSION.REQ_ISAJAX -%]
    [% TT_VARS.make_it_simple=1 -%]
[% END #UNLESS SESSION.REQ_ISAJAX -%]
<table cellpadding="4" cellspacing="0" class="cellable_tbl w100">
    <tr>
        <td colspan="3">
            <a href="/"><h1>&quot;Made in couple hours&quot; MjNCMS example</h1></a>
        </td>
    </tr>
    <tr>
        <td class="w15 lual nwp">
            [% mids = TT_CALLS.menus_get_record_tree('onsite') -%]
            [% IF mids.size %]
                <ul>
                [% mids_data = TT_CALLS.menus_get_record(mids).records -%]
                [% FOREACH mid=mids -%]
                    <li>
                        <a[% IF mids_data.${mid}.link == SESSION.CURRENT_PAGE %] class="b"[% END %] href="[% bytestream(mids_data.${mid}.link, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]">[% mids_data.${mid}.text %]</a>
                    </li>
                [% END #FOREACH -%]
                </ul>
            [% END #IF mids.size -%]
        </td>
        <td class="lual">
            [% TRY -%]
                [% prs_tplname = tt_controller _ '/' _ tt_controller _ '_' _ tt_action _ '.tpl' -%]
                [% INCLUDE $prs_tplname -%]
            [% CATCH -%]
                [% loc('Error') -%]: [% loc('Unable load action template.') -%]<br />
                <b>tt_controller:</b> '[% tt_controller | html %]'<br />
                <b>tt_action:</b> '[% tt_action | html %]'<br />
                [% prs_tplname = tt_controller _ '/' _ tt_controller _ '_' _ tt_action _ '.tpl' %]
                <b>tpl file to include:</b> '[% prs_tplname | html %]'<br />
                [% IF error %][% loc('Error text') -%]: <i>[% error.info | html -%]</i>[% END -%]
            [% END -%]
        </td>
        <td class="w15 lual">
            Some blocks:
            [% INCLUDE common_blocks_fmt.tpl 
                t_block_alias='anybody_block ', 
            -%]
        </td>
    </tr>
</table>
[% UNLESS SESSION.REQ_ISAJAX -%]
<div id="body_tmp_container">&nbsp;</div>
[% END #UNLESS SESSION.REQ_ISAJAX -%]
<div align="center">
    2010 &copy; <a href="http://lefedor.blogspot.com/" target="_blank">FedorFL</a> (<a href="http://github.com/lefedor/mjncms" target="_blank">MjNCMS</a>)
</div>
