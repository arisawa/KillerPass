package KillerPass;
use strict;
use warnings;

use YAML::Tiny qw(LoadFile DumpFile);
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(time);
use Path::Class;
use Config::Pit;
use IO::Interface::Simple;

our $VERSION = '0.01';

my $port = $ENV{PORT} || 5000;
my $home = dir(__FILE__)->parent->parent;
my $yaml = "$home/keys.yaml";

sub get {
    my ($key, $hash) = @_;

    my $keys = LoadFile($yaml);
    my $pit_key;
    map {
        $pit_key = $_
            if ($keys->{$_} eq $hash)
    } keys %$keys;
    return unless $pit_key;

    my $config = pit_get($pit_key);
    return ($config->{username}, $config->{password});
}

sub set {
    my ($key, $username, $password) = @_;
    my $keys = LoadFile($yaml);

    my $hash = md5_hex($key.$username.$password.time());
    my $pit_key = "killerpass:$key:$username";
    $keys->{$pit_key} = $hash;

    Config::Pit::set($pit_key, data => {
        username => $username,
        password => $password,
    });
    DumpFile($yaml, $keys);

    my $address = '0';
    for my $if (IO::Interface::Simple->interfaces) {
        if ($if->name =~ /^(en0|bond0|eth0)$/) {
            next unless $if->address;
            $address = $if->address;
            last;
        }
    }
    sprintf "http://%s:%s/killerpass/get/%s/%s", $address, $port, $key, $hash;
}

sub set_link {
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
