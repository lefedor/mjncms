[% USE loc -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%">
    <tr>
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %]>
            [% loc('No access permissions to this action/page') %]
        </td>
    </tr>
	<tr>
		<td class="nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			[% loc('Sorry, you are not allowed to open this page') -%]
		</td>
	</tr>
</table>
