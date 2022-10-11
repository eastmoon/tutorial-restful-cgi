#!/usr/bin/env perl

# Import library
use JSON;
use Switch;

# Declare function
sub parser_request_info {
    $CONTNET = "";
    $CONTENT_TYPE = $ENV{'CONTENT_TYPE'};
    $CONTENT_LENGTH = $ENV{'CONTENT_LENGTH'};
    if ( ! $CONTENT_LENGTH eq "" ) {
        read (STDIN, $CONTENT, $ENV{'CONTENT_LENGTH'});
    }
    %req=(
        "REQUEST_METHOD"=>$ENV{'REQUEST_METHOD'},
        "REQUEST_URI"=>$ENV{'REQUEST_URI'},
        "SCRIPT_FILENAME"=>$ENV{'SCRIPT_FILENAME'},
        "SCRIPT_NAME"=>$ENV{'SCRIPT_NAME'},
        "QUERY_STRING"=>$ENV{'QUERY_STRING'},
        "CONTENT_TYPE"=>$CONTENT_TYPE,
        "CONTENT_LENGTH"=>$CONTENT_LENGTH,
        "CONTENT"=>$CONTENT
    );
    return \%req
}

sub parser_restful_info {
    my($url) = @_;
    # Regex for get the related fields from URL
    $url =~ m/(\w+)\/(\w+)\/(\w+)/;
    %re = (
        "api"=>$1,
        "id"=>$2,
        "name"=>$3
    );
    return \%re;
}

sub response {
    my($status, $message) = @_;
    %obj=(
        "status"=>$status,
        "message"=>$message
    );
    $json_text_obj = encode_json \%obj;
    print "Content-type: application/json";
    print "\n\n";
    print "$json_text_obj\n";
}

sub call_get {
    my($info) = @_;
    %ret = (
        "text"=>"Call GET method, and retrieve information.",
        "body"=>$info
    );
    return \%ret;
}

sub call_post {
    my($info) = @_;
    $json_obj_ref = decode_json $info{"req"}{"CONTENT"};
    %ret = (
        "text"=>"Call POST method, new information with body.",
        "body"=>$json_obj_ref
    );
    return \%ret;
}

sub call_put {
    my($info) = @_;
    $json_obj_ref = decode_json $info{"req"}{"CONTENT"};
    %ret = (
        "text"=>"Call PUT method, update information with body.",
        "body"=>$json_obj_ref
    );
    return \%ret;
}

sub call_del {
    my($info) = @_;
    return "Call DELETE method, and remove information."
}
# Execute script
$req = &parser_request_info();
%info = (
    "restful"=>&parser_restful_info($req{"SCRIPT_NAME"}),
    "req"=>$req
);
switch($req{"REQUEST_METHOD"}) {
    case "GET"    { $result = &call_get(\%info); }
    case "POST"    { $result = &call_post(\%info); }
    case "PUT"    { $result = &call_put(\%info); }
    case "DELETE"    { $result = &call_del(\%info); }
}
&response("success", $result);
