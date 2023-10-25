package UrlTemplate::Checker;

use v5.36;
use strict;
use warnings;
no warnings 'experimental::builtin';
use List::AllUtils qw/first all/;

=head1 NAME

UrlTemplate::Checker - checks URL within templates list

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use UrlTemplate::Checker;

    my $checker = UrlTemplate::Checker->new();
    $checker->append_paths(
        '/api/v1/:storage/:pk/raw',
        '/api/v1/:storage/:pk/:op',
        '/api/v1/:storage/:pk',
    );
    my ($index, $keys) = $checker->check('http://localhost:8080/api/v1/order/123/update');
    
    undef returned if no viable template was found
=cut

=head2 new
    creates checker object
=cut

sub new($class) {
    my $self = {
        raw_paths    => [],
        parsed_paths => []
    };
    return bless $self, $class;
}

=head2 append_paths(@paths)
    appends a paths to internal storage
=cut
sub append_paths($self, @paths) {
    push $self->{raw_paths}->@*, @paths;
    $self->_parse_path($_) for @paths;
}

sub _parse_path($self, $path) {
    use Data::Dumper;
    my $noroot = $path =~ s|^/||r;
    my @path_tokens = split /\//, $noroot;
    # ':' represents key name, 't' represents token
    push $self->{parsed_paths}->@*, [ map {/^:(\w+)/ ? [ ':' => $1 ] : [ 't' => $_ ]} @path_tokens ];
}

=head2 check($url)
    checks url within stored paths
=cut

sub check($self, $url) {
    my $cleaned_url = $url =~ s|^\w+://[\w.]+(?::\d+)/||r;
    my $url_parsed = [ split /\//, $cleaned_url ];
    my $result;
    my $index = first {
        # iterating by stored paths
        my $path_struct = $self->{parsed_paths}[$_];
        $result = {};
        @$path_struct == @$url_parsed && all {
            # iterating by url path tokens
            my $url_part = $url_parsed->[$_];
            my $path_part = $path_struct->[$_];

            if ($path_part->[0] eq ':') {
                # is a key
                $result->{$path_part->[1]} = $url_part;
                builtin::true; # a key is always matched
            }
            else { # is not a key - a token
                $url_part eq $path_part->[1];
            }
        } 0 .. $#$url_parsed;
    } 0 .. $self->{parsed_paths}->$#*;
    return $index, $result if defined $index;
    return undef;
}

=head1 AUTHOR

Dmithry Petrov, C<< <dmithry.petrov at gmail.com> >>


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by Dmithry Petrov.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut

builtin::true; # End of UrlTemplate::Checker
