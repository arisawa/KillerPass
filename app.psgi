use FindBin;
use lib "$FindBin::Bin/lib";
use KillerPass;

my $CONTENT_TYPE = [ 'Content-Type' => 'text/html' ];
my %URL_MAP = (
    example => 'http://example.com/',
);

my $app = sub {
    my $env = shift;

    if ($env->{PATH_INFO} =~ m{^/killerpass/get/([^/]+)/([^/]+)$}) {
        my($key, $hash) = ($1, $2);
        my $url = defined $URL_MAP{$key} ? $URL_MAP{$key} : undef;
        $url = KillerPass::set_link($url);
        my ($id, $pw) = KillerPass::get($key, $hash);

        return $id
            ? [ 200, $CONTENT_TYPE, [ join '<br />', grep { $_ } $url, $id, $pw ] ]
            : [ 500, $CONTENT_TYPE, [ 'Unknown keys' ] ];
    }

    if ($env->{PATH_INFO} =~ m{^/killerpass/set/([^/]+)/([^/]+)/([^/]+)$}) {
        my $get_url = KillerPass::set($1, $2, $3);
        return $get_url
            ? [ 200, $CONTENT_TYPE, [ $get_url ] ]
            : [ 500, $CONTENT_TYPE, [ 'Unknown keys' ] ];
    }

    return [ 404, $CONTENT_TYPE, [ '404 Not Found' ] ];
};
