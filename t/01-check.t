#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw/no_plan/;

use_ok('UrlTemplate::Checker');
subtest 'Unique url with keys' => sub {
    my $checker = new_ok('UrlTemplate::Checker');
    $checker->append_paths(
        '/api/v1/:storage/:pk/raw',
        '/api/v1/:storage/:pk/:op',
        '/api/v1/:storage/:pk',
    );
    my ($index, $result) = $checker->check('http://localhost:8080/api/v1/order/123/update');
    ok(defined $index && $index == 1);
    is_deeply($result, {
        'pk'      => '123',
        'op'      => 'update',
        'storage' => 'order'
    });
};

subtest 'unique url with no keys' => sub {
    my $checker = new_ok('UrlTemplate::Checker');
    $checker->append_paths(
        '/api/v1/:storage/:pk/raw',
        '/api/v1/:storage/:pk/:op',
        '/api/v1/:storage/:pk',
        '/api/v2/order/123/update'
    );
    my ($index, $result) = $checker->check('http://localhost:8080/api/v2/order/123/update');
    ok(defined $index && $index == 3);
    is_deeply($result, {});
};

subtest 'Non-unique paths' => sub {
    my $checker = new_ok('UrlTemplate::Checker');
    $checker->append_paths(
        '/api/v1/:storage/:pk/raw',
        '/api/v2/order/123/update',
        '/api/v1/:storage/:pk/:op',
        '/api/v1/:storage/:pk',
        '/api/v2/order/123/update'
    );
    my ($index, $result) = $checker->check('http://localhost:8080/api/v2/order/123/update');
    ok(defined $index && $index == 1);
    is_deeply($result, {});
};

subtest 'Url not found' => sub {
    my $checker = new_ok('UrlTemplate::Checker');
    $checker->append_paths(
        '/api/v1/:storage/:pk/raw',
        '/api/v2/order/123/update',
        '/api/v1/:storage/:pk/:op',
        '/api/v1/:storage/:pk',
        '/api/v2/order/123/update'
    );
    my $index = $checker->check('http://localhost:8080/api/v3/order/123/update');
    ok(!defined $index);
};
