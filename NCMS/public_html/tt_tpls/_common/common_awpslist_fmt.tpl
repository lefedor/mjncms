[%#
t_awprole - TT_CALLS.awproles_get() obj
t_mode = list-chk/list-radio/select
t_disabled = disable fields default
t_name - name 
t_id - id 
t_noawp - add option 'No user' (value=='no', for selects)
t_anyawp - add option 'Any' (value=='any', for selects)
t_onlyselected - hash wthk keys - 'show only w keys'
t_selmultible - multible attrib to select field
t_selected - mark as checked/selected, hash
t_selectedall - mark all as checked/selected
-%]
[% USE loc -%]
[% UNLESS t_awprole -%]
	[% awprole=TT_CALLS.awproles_get() -%]
	[% IF awprole.message -%]
		[% loc('Permissions list receiving fail') | html -%]:[% awprole.message | html -%]
		[% RETURN -%]
	[% END -%]
	[%# awprole.qr -%]
	[%# awprole.qa -%]
[% ELSE -%]
	[% awprole=t_awprole -%]
[% END -%]
[% UNLESS t_mode && (t_mode=='select' || t_mode=='list-chk' || t_mode=='list-radio') -%]
	[% t_mode='select' -%]
[% END -%]
[% UNLESS t_name -%]
	[% t_name='awp_id' -%]
[% END -%]
[% UNLESS t_id -%]
	[% t_id=t_name -%]
[% END -%]
[% IF awprole.awps_seq_list.size || t_noawp || t_anyawp -%]
    [% IF t_mode=='select' -%]
    <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %][% IF t_selmultible %] multiple size="[% t_selmultible %]"[% END %]>
        [% IF t_noawp -%]
            <option value="no"[% IF !t_selectedall && (!t_selected || t_selected.no) %] selected="selected"[% END %]>[% loc('No AWP') %]</option>
        [% END -%]
        [% IF t_anyawp -%]
            <option value="any"[% IF !t_selectedall && (!t_selected || t_selected.any) %] selected="selected"[% END %]>[% loc('Any AWP') %]</option>
        [% END -%]
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        <ul>
    [% END -%]
    [% FOREACH awp_id=awprole.awps_seq_list -%]
		[% awp = awprole.awps.$awp_id -%]
        [% IF !t_onlyselected || t_selected.$qwp_id -%]
            [% IF t_mode=='select' -%]
                <option [% IF t_selectedall || t_selected.$awp_id %] selected="selected"[% END %] value="[% awp_id %]">[% awp.name | html %]</option>
            [% ELSIF t_mode=='list-chk' -%]
                <li><input[% IF t_selectedall || t_selected.$awp_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% awp_id %]" name="[% t_name %]_[% awp_id %]" id="[% t_id %]_[% awp_id %]" /><label for="[% t_id %]_[% awp_id %]">[% awp.name | html %]</label></li>
            [% ELSIF t_mode=='list-radio' -%]
                <li><input[% IF t_selectedall || t_selected.$awp_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% awp_id %]" name="[% t_name %]" id="[% t_id %]_[% awp_id %]" /><label for="[% t_id %]_[% awp_id %]">[% awp.name | html %]</label></li>
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
			<li>[% loc('No AWPs found') | html -%]</li>
		</ul>
    [% ELSIF t_mode=='select' -%]
        <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %]>
            <option value="">[% loc('No AWPs found') | html -%]</option>
        </select>
    [% END -%]
[% END -%]
