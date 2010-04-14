[%#
t_mode = list-chk/list-radio/select
t_disabled = disable fields default
t_name - name 
t_id - id 
t_nolang - add option 'No user' (value=='no', for selects)
t_anylang - add option 'Any' (value=='any', for selects)
t_onlyselected - hash wthk keys - 'show only w keys'
t_selmultible - multible attrib to select field
t_selected - mark as checked/selected, hash
t_selectedall - mark all as checked/selected
-%]
[% USE loc -%]
[% UNLESS t_mode && (t_mode=='select' || t_mode=='list-chk' || t_mode=='list-radio') -%]
	[% t_mode='select' -%]
[% END -%]
[% UNLESS t_name -%]
	[% t_name='lang' -%]
[% END -%]
[% UNLESS t_id -%]
	[% t_id=t_name -%]
[% END -%]
[% langs_res=SESSION.LOC.get_langs_list() -%]
[% IF langs_res.keys.size || t_nolang || t_anylang -%]
    [% IF t_mode=='select' -%]
    <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %][% IF t_selmultible %] multiple size="[% t_selmultible %]"[% END %]>
        [% IF t_nolang -%]
            <option value="no_lang"[% IF !t_selectedall && (!t_selected || t_selected.no) %] selected="selected"[% END %]>[% loc('No lang') %]</option>
        [% END -%]
        [% IF t_anylang -%]
            <option value="any_lang"[% IF !t_selectedall && (!t_selected || t_selected.any) %] selected="selected"[% END %]>[% loc('Any lang') %]</option>
        [% END -%]
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        <ul>
    [% END -%]
    [% FOREACH lang_key=langs_res.keys.sort -%]
        [% IF !t_onlyselected || t_selected.$lang_key -%]
            [% IF t_mode=='select' -%]
                <option value="[% lang_key | html %]"[% IF t_selectedall || t_selected.$lang_key %] selected="selected"[% END #IF lang_key %]>[% loc(langs_res.$lang_key.name) | html %]</option>
            [% ELSIF t_mode=='list-chk' -%]
                <li><input[% IF t_selectedall || t_selected.$lang_key %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% lang_key | html %]" name="[% t_name %]_[% m_id %]" id="[% t_id %]_[% m_id %]" /><label for="[% t_id %]_[% m_id %]">[% loc(langs_res.$lang_key.name) | html %]</label></li>
            [% ELSIF t_mode=='list-radio' -%]
                <li><input[% IF t_selectedall || t_selected.$lang_key %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% lang_key | html %]" name="[% t_name %]" id="[% t_id %]_[% m_id %]" /><label for="[% t_id %]_[% m_id %]">[% loc(langs_res.$lang_key.name) | html %]</label></li>
            [% END -%]
        [% END -%]
    [% END #FOREACH -%]
    [% IF t_mode=='select' -%]
        </select>
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        </ul>
    [% END -%]
[% ELSE -%]
    [% IF t_mode=='list-chk' || t_mode=='list-radio' -%]
		<ul>
			<li>[% loc('No langs found') | html -%]</li>
		</ul>
    [% ELSIF t_mode=='select' -%]
        <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %]>
            <option value="">[% loc('No langs found') | html -%]</option>
        </select>
    [% END -%]
[% END -%]
