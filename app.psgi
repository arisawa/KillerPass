use FindBin;
use lib "$FindBin::Bin/lib";
use KillerPass;

my $CONTENT_TYPE = [ 'Content-Type' => 'text/html' ];

my $app = sub {
    my $env = shift;

    my $content;
    if ($env->{PATH_INFO} =~ m{^/killerpass/get/(\w+)/(\w+)$}) {
        $content = KillerPass::get_password($1, $2);
    } elsif ($env->{PATH_INFO} =~ m{^/killerpass/set/(\w+)/(\w+)/(\w+)$}) {
        $content = KillerPass::set_password($1, $2, $3);
    } elsif ($env->{PATH_INFO} =~ m{^/killerpass/urls$}) {
        $content = KillerPass::urls;
    } else {
        return [ 404, $CONTENT_TYPE, [ '404 Not Found' ] ];
    }

    return $content
        ? [ 200, $CONTENT_TYPE, [ $content ] ]
        : [ 500, $CONTENT_TYPE, [ 'Unknown keys' ] ];
};
