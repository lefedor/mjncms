[%- UNLESS TT_VARS.make_it_simple -%]
[%- DEFAULT TT_VARS.title=TT_VARS.site_name -%]
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="[% TT_VARS.html_lang %]" xml:lang="[% TT_VARS.xml_lang %]">
	<head>
		<title>[% TT_VARS.title %]</title>
		<meta http-equiv="Content-Type" content="text/html; charset=[% TT_VARS.html_charset %]" />
		[% END #UNLESS TT_VARS.make_it_simple -%]
			[%- IF TT_VARS.CSS.size -%]
				[% TT_VARS.CSS=TT_CALLS.sort_jscss(TT_VARS.CSS) -%]
				[% FOREACH css_url=TT_VARS.CSS %]
					<link rel="stylesheet" type="text/css" href="[% css_url | html %]" />
				[%- END #FOREACH css_url=TT_VARS.CSS -%]
			[% END #IF TT_VARS.CSS.size -%]
			[%- IF TT_VARS.JS.size -%]
				[% TT_VARS.JS=TT_CALLS.sort_jscss(TT_VARS.JS) -%]
				[% FOREACH js_url=TT_VARS.JS %]
					<script src="[% js_url | html %]" type="text/javascript"></script>
				[%- END #FOREACH css_url=TT_VARS.JS -%]
			[% END #IF TT_VARS.JS.size %]
		[%- UNLESS TT_VARS.make_it_simple %]
		<meta name="robots" content="[% UNLESS TT_VARS.ROBOTS_NOINDEX %]index[% ELSE %]noindex[% END %],[% UNLESS TT_VARS.ROBOTS_NOFOLLOW %]follow[% ELSE %]nofollow[% END %]" />
	</head>
	<body id="body_container_id">
		[% END #UNLESS TT_VARS.make_it_simple -%]
			[%- content #this focus provided by TT WRAPPER OPT -%]
		[%- UNLESS TT_VARS.make_it_simple %]
	</body>
</html>
[%- END #UNLESS TT_VARS.make_it_simple -%]
