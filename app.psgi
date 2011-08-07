use FindBin;
use lib "$FindBin::Bin/lib";
use KillerPass;

my $CONTENT_TYPE = [ 'Content-Type' => 'text/plain' ];
my %URL_MAP = (
    example => 'http://example.com/',
);

my $app = sub {
    my $env = shift;

    if ($env->{PATH_INFO} =~ m{^/killerpass/([^/]+)/([^/]+)$}) {
        my($key, $hash) = ($1, $2);
        my $url = defined $URL_MAP{$key} ? "$URL_MAP{$key}: " : "";
        my $info = KillerPass::get ($key, $hash);
        return $info
            ? [ 200, $CONTENT_TYPE, [ $url.$info ] ]
            : [ 500, $CONTENT_TYPE, [ 'Unknown keys' ] ];
    }

    # for test
    # if ($env->{PATH_INFO} =~ m{^/set/ ([^/]+)/ ([^/]+)/([^/]+)$}) {
    #     my $info = KillerPass::set($1, $2, $3);
    #     return $info
    #         ? [ 200, $CONTENT_TYPE, [ $url.$info ] ]
    #         : [ 500, $CONTENT_TYPE, [ 'Unknown keys' ] ];
    # }

    return [ 404, $CONTENT_TYPE, [ '404 Not Found' ] ];
};
