#!/usr/bin/env perl

# Import library
use JSON;

# Response
my %hash=("v1"=>"aaa", "v2"=>"bbb", "v3"=>"ccc");
$json_text_hash = encode_json \%hash;

print "Content-type: application/json";
print "\n\n";
print "$json_text_hash";
