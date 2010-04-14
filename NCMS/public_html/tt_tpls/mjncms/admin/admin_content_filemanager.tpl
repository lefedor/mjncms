[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.STATICFILES_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/_static/js/FileManager.js') -%]
[% TT_VARS.CSS.push(bytestream(SESSION.STATICFILES_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/_static/css/FileManager.css') -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Filemanager') -%]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="height:500px;padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<div id="FmContainer" />
			<!-- Here should be CKFINDER File manager, but because fucking demo message, I've been forced to write own one. -->

			<script type="text/javascript">
				var FM = false;
				window.addEvent('load', function(){
					FM = new FileManager('FmContainer', {'fileDblClickFunction': false});
				});
				
			</script>
		</td>
	</tr>
</table>

