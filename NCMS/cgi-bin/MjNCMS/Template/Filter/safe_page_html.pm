package MjNCMS::Template::Filter::safe_page_html;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#Safe html tags for pages. NOT FOR comments or smth.

#
# Bender: My head! My precious head!
#   Stuped cun opener! 
#   You've killed my father and now you've come back for me!
#

BEGIN {
  use common::sense;
  use Template::Plugin::Filter;
  use base qw(Template::Plugin::Filter);
  use FindBin;
  use lib "$FindBin::Bin/../../..";
  #use MjNCMS::Config qw/:vars/;
  
  #filter possibly unsafe html. EVIL :)
  #disallow all not allowed
  use HTML::StripScripts::Parser;
}

our $VERSION = 1.00;

sub new {
    my ($class, $context, $format) = @_;;
    $context->define_filter('safe_page_html', [ \&safe_page_html_filter_factory => 1 ]);
    return \&safe_page_html;
}

sub filter {
    my ($self, $html) = @_;
    return $self->safe_page_html($html);
}

sub safe_page_html ($) {
    my $html = shift;
    return '' unless defined $html && length $html;

    #This would be bad, evil, very unfair parser :)
    my $hss = HTML::StripScripts::Parser->new(
       { 
        Context => 'Flow',
        AllowSrc => 1,
        AllowHref => 1,
        AllowRelURL => 1,
        BanAllBut => [qw/

            b strong 
            u strike em 

            sup sub 

            ul li 

            p div span style

            a 

            h1 h2 h3 h4 h5 h6 

            img

            table tbody tr td th
            
            object param embed

        /],
        Rules => {
            a => {
                'href' => '^(\/|ftp|http|https|ftp|)', #no javascript:, 
                
                'alt' => 1,
                'title' => 1,
                
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                
                'target' => 1, 
                'name' => 1, 
            },
            img => {
                'src' => '^(\/|ftp|http|https|ftp|)[^\"]+\.(gif|jpg|jpeg|png)$', 
                'lowsrc' => '^(\/|ftp|http|https|ftp|)[^\"]+\.(gif|jpg|jpeg|png)$', 
                 
                'alt' => 1,
                'title' => 1,

                'width' => 1, 
                'height' => 1, 
                'border' => 1,
                 
                'style' => 1, 
                'class' => 1, 
                'align' => 1,  
                'float' => 1,
            },
            span => {
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                'float' => 1,
            },
            div => {
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                'float' => 1,
            },
            table => {
                'cellpadding' => 1, 
                'cellspacing' => 1, 
                
                'width' => 1, 
                'height' => 1,
                'border' => 1,
                                 
                'align' => 1,  
                'style' => 1, 
                'class' => 1, 
            },
            tr => {
                'rowspan' => 1, 
                'height' => 1, 
            },
            td => {
                'colspan' => 1, 
                'width' => 1, 
                'height' => 1, 
            },
            object => {
                'classid' => 1, 
                'codebase' => 1, 
            },
            param => {
                'name' => 1, 
                'value' => 1, 
            },
            embed => {
                'src' => '^(\/|ftp|http|https|ftp|)$', 
                'type' => 1, 
                'allowscriptaccess' => 1, 
                'allowfullscreen' => 1, 
                'width' => 1, 
                'height' => 1, 
            },
            '*' => {
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                '*' => 0, #no onclicks and other stuff
            }, 
        },
        EscapeFiltered  => 0,
       },
       strict_comment => 1,
       strict_names   => 1,
       
    );

    #### fetch default allowed tags and attributes
    #
    #my $context_whitelist = $hss->init_context_whitelist();
    #my $attrib_whitelist = $hss->init_attrib_whitelist();
    #
    #### set additionally allowed html tags
    #$context_whitelist->{'Flow'}->{'object'} = 'object';
    #$context_whitelist->{'Inline'}->{'object'} = 'object';
    #$context_whitelist->{'object'}->{'param'} = 'EMPTY';
    #$context_whitelist->{'object'}->{'embed'} = 'EMPTY';
    #
    #### set additionally allowed html tag attributes
    #$attrib_whitelist->{'a'}->{'href'} = 'word';
    #$attrib_whitelist->{'a'}->{'name'} = 'word';
    #$attrib_whitelist->{'a'}->{'title'} = 'text';
    #$attrib_whitelist->{'a'}->{'class'} = 'wordlist';
    #$attrib_whitelist->{'a'}->{'target'} = 'word';

    return $hss->filter_html($html);
    
}; #-- safe_html

sub safe_page_html_filter_factory {
    my ($context, @args) = @_;
    return sub {
        my $html = shift;
        return &safe_page_html($html, @args);
    }
}

1;
