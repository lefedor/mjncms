[% USE loc -%]
<h2>[% loc('Create a new short link') | html %]</h2>

<form name="add_surl_frm" id="add_surl_frm" action="[% SESSION.URL_LANG_PREFIX %][% SESSION.SHORTLINKS_URL %]/add" method="post" accept-charset="[% TT_VARS.html_charset %]">
    <table border="0" cellpadding="4" cellspacing="0" class="transp_table">
        <tr>
            <td>
                <label for="alias">[% loc('Alias (optional)') | html %]: </label>
            </td>
            <td>
                <input type="text" name="alias" id="alias" size="9" maxlength="8"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="orig_url">[% loc('Original URL') | html %]: </label>
            </td>
            <td>
                <input type="text" name="orig_url" id="orig_url" size="40" />
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <input type="submit" value="[% loc('Add new URL') | html %]" />
            </td>
        </tr>
    </table>
    <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
</form>
