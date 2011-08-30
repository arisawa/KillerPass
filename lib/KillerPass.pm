package KillerPass;
use strict;
use warnings;

use YAML::Tiny qw(LoadFile DumpFile);
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(time);
use Path::Class;
use Config::Pit ();
use IO::Interface::Simple;

our $VERSION = '0.01';

my $port = $ENV{PORT} || 5000;
my $home = dir(__FILE__)->parent->parent;
my $keys_yaml = "$home/keys.yaml";
my $urls_yaml = "$home/urls.yaml";

sub get_password {
    my ($urlkey, $hash) = @_;

    my $keys = LoadFile($keys_yaml);
    my $urls = LoadFile($urls_yaml);

    return unless defined $urls->{$urlkey};

    my $pit_key = _pit_key($keys, $hash);
    return unless $pit_key;

    my $config = Config::Pit::pit_get($pit_key);
    my $url    = _set_link($urls->{$urlkey});

    join '<br />', $url, $config->{username}, $config->{password};
}

sub _pit_key {
    my ($keys, $hash) = @_;
    my ($key) = grep { $keys->{$_} eq $hash } keys %$keys;
    $key;
}

sub set_password {
    my ($key, $username, $password) = @_;

    my $keys = LoadFile($keys_yaml);
    my $hash = md5_hex($key.$username.$password.time());
    my $pit_key = "killerpass:$key:$username";
    $keys->{$pit_key} = $hash;

    Config::Pit::set($pit_key, data => {
        username => $username,
        password => $password,
    });
    DumpFile($keys_yaml, $keys);

    my $address = '0';
    for my $if (IO::Interface::Simple->interfaces) {
        if ($if->name =~ /^(en0|bond0|eth0)$/) {
            next unless $if->address;
            $address = $if->address;
            last;
        }
    }
    my $url = sprintf "http://%s:%s/killerpass/get/%s/%s", $address, $port, $key, $hash;
    _set_link($url);
}

sub urls {
    my $urls = shift;
    $urls ||= LoadFile($urls_yaml);

    my $content = '<dt>site_key</dt><dd>site_url</dd>';
    $content .= join "", map {
        my $url = _set_link($urls->{$_});
        "<dt>$_</dt><dd>$url</dd>"
    } sort keys %$urls;

    "<dl>$content</dl>";
}

sub _set_link {
    my $url = shift;
    $url ? qq|<a href="$url">$url</a>| : "";
}

1;

__END__

=head1 NAME

KillerPass - Password display for Intranet

=head1 SYNOPSIS

  use KillerPass;

=head1 DESCRIPTION

KillerPass is

=head1 AUTHOR

Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
