use strict;
use warnings;
use Test::More;
use Path::Class;
use YAML::Tiny qw(LoadFile);
use KillerPass;

my $home = dir(__FILE__)->parent->parent;
my $keys = LoadFile("$home/t/test_keys.yaml");
my $urls = LoadFile("$home/t/test_urls.yaml");


is  KillerPass::_pit_key($keys, 'hogehash'), 'killerpass:hoge:id', 'get pitkey';
is  KillerPass::_pit_key($keys, 'haaash'), 'killerpass:hooo:email', 'get pitkey';
ok !KillerPass::_pit_key($keys, 'bash'), 'get pitkey failed';

is KillerPass::_set_link('link'), qq|<a href="link">link</a>|, 'set_link';
is KillerPass::urls($urls), qq|<dl><dt>site_key</dt><dd>site_url</dd><dt>foo</dt><dd><a href="http://example.foo.net">http://example.foo.net</a></dd><dt>hoge</dt><dd><a href="http://example.hoge.com">http://example.hoge.com</a></dd></dl>|, 'urls';

ok !KillerPass::get_password('nothingurlkey', 'nothinghash'), 'nothing urlkey';
done_testing;
