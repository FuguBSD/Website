#!/usr/bin/env perl
# ex:ts=8 sw=4:
# scripts/rotate-key: one whole rotation of a release key.
#
# The test runs the script over a site in a File::Temp directory, and
# it verifies each signature with signify(1). It never reads this
# repository, so a change to .fuguwebrc cannot break it.
#
# The test needs signify(1) and the Fugu library. The rotation
# workflow installs both, and this file skips without them.

use v5.36;
use Test::More;
use FindBin qw($RealBin);
use File::Path qw(make_path);
use File::Temp qw(tempdir);

# have($tool):
#	Report whether the program is on the path.
sub have ($tool)
{
	return system("command -v $tool >/dev/null 2>&1") == 0;
}

my $SIGNIFY =
      have('signify-openbsd') ? 'signify-openbsd'
    : have('signify')         ? 'signify'
    :                           undef;

# The whole file drives the script, so the skip comes before the
# first assertion. A plan that arrives after one is not a plan.
plan skip_all => 'signify not found' unless defined $SIGNIFY;
plan skip_all => 'Fugu::KeyDir not installed'
    unless eval { require Fugu::KeyDir; 1 };

my $SCRIPT = "$RealBin/../scripts/rotate-key";
ok( -x $SCRIPT, 'the script is executable' );

my $RC = <<'RC';
site = Example

keys "keys" {
	org = fugubsd
	url = https://www.fugubsd.org/keys
}
RC

# site():
#	A site with an empty key directory, and its root.
sub site ()
{
	my $root = tempdir( CLEANUP => 1 );
	make_path("$root/web/keys");

	open my $fh, '>', "$root/.fuguwebrc"
	    or die "Cannot write the description: $!";
	print {$fh} $RC;
	close $fh;

	return $root;
}

# rotate($root, @argv):
#	Run one step of the script, and return its output as a hash of
#	name to value. A failure fails the test and returns nothing.
sub rotate ( $root, @argv )
{
	my @cmd = ( $^X, $SCRIPT, '--root', $root, @argv );
	my $out = `@{[ join ' ', map { qq{'$_'} } @cmd ]} 2>&1`;
	unless ( $? == 0 ) {
		fail("rotate-key @argv");
		diag $out;
		return;
	}

	return { map { split /=/, $_, 2 } grep { /=/ } split /\n/, $out };
}

# verified($root, $key):
#	Report whether the key verifies the manifest of the site.
sub verified ( $root, $key )
{
	my $dir = "$root/web/keys";

	# signify(1) writes its failure to standard error, and a
	# negative case here is a pass. The message would read like a
	# broken test in the output of the run.
	open my $saved, '>&', \*STDERR or die "Cannot save stderr: $!";
	open STDERR, '>', '/dev/null' or die 'Cannot silence stderr';

	my $status =
	    system( $SIGNIFY, '-V', '-q', '-p', "$dir/$key",
		'-m', "$dir/SHA256", '-x', "$dir/SHA256.sig" );

	open STDERR, '>&', $saved or die "Cannot restore stderr: $!";

	return $status == 0;
}

# slurp($path):
#	The whole file, as bytes.
sub slurp ($path)
{
	open my $fh, '<', $path or die "Cannot read $path: $!";
	binmode $fh;
	my $bytes = do { local $/; <$fh> };
	close $fh;

	return $bytes;
}

my $root = site();
my ( $one, $two ) = ( "/$$-one.sec", "/$$-two.sec" );
my $secrets = tempdir( CLEANUP => 1 );
$one = "$secrets$one";
$two = "$secrets$two";

subtest 'the first mint makes a current key' => sub {
	my $made = rotate( $root, '--step', 'mint', '--purpose', 'release',
		'--secret', $one )
	    or return;

	is( $made->{name},   'fugubsd-1-release.pub', 'the file name' );
	is( $made->{serial}, 1,                       'the serial starts at 1' );
	is( $made->{status}, 'current',
		'and the first key of a purpose is current at once' );

	ok( -f "$root/web/keys/fugubsd-1-release.pub", 'the key is written' );
	ok( -s $one, 'and the private half went to the named path' );
	is( ( stat $one )[2] & 07777, 0600, 'with no group and no other' );

	# signify(1) writes ' public key' after the comment that the
	# caller names, so the published comment is the form that the
	# key directory states.
	like( slurp("$root/web/keys/fugubsd-1-release.pub"),
		qr/\Auntrusted comment: fugubsd-1-release public key\n/,
		'and the untrusted comment names the key' );

	like( slurp("$root/.fuguwebrc"),
		qr/key "fugubsd-1-release" \{\n\tstatus = current\n/,
		'the description holds the key block' );

	# The first key signs its own manifest: no other key exists.
	like( slurp("$root/web/keys/SHA256"),
		qr/\ASHA256 \(fugubsd-1-release\.pub\) = [0-9a-f]{64}\n\z/,
		'the manifest names the key' );
	ok( verified( $root, 'fugubsd-1-release.pub' ),
		'and the key verifies it' );
};

subtest 'a second mint makes a next key' => sub {
	my $made = rotate(
		$root,     '--step',  'mint', '--purpose',
		'release', '--secret', $two,  '--signer',
		$one
	) or return;

	is( $made->{name},   'fugubsd-2-release.pub', 'the file name' );
	is( $made->{serial}, 2,                       'the serial adds one' );
	is( $made->{status}, 'next',
		'and a purpose with a current key gets a next key' );

	like( slurp("$root/.fuguwebrc"),
		qr/key "fugubsd-2-release" \{\n\tstatus = next\n/,
		'the description holds the new block' );

	my $manifest = slurp("$root/web/keys/SHA256");
	like( $manifest, qr/fugubsd-1-release\.pub/, 'the manifest names both' );
	like( $manifest, qr/fugubsd-2-release\.pub/, 'keys' );

	# The current key vouches for the next one. A consumer that
	# holds the old copy of deps/KEYS.txt can still verify.
	ok( verified( $root, 'fugubsd-1-release.pub' ),
		'the current key signs the manifest' );
	ok( !verified( $root, 'fugubsd-2-release.pub' ),
		'and the next key does not' );
};

subtest 'the promote makes the next key current' => sub {
	my $made = rotate( $root, '--step', 'promote', '--purpose', 'release',
		'--secret', $two )
	    or return;

	is( $made->{name},    'fugubsd-2-release.pub', 'the new current key' );
	is( $made->{status},  'current',               'takes the status' );
	is( $made->{retired}, 'fugubsd-1-release.pub', 'and the old one goes' );

	my $rc = slurp("$root/.fuguwebrc");
	like( $rc, qr/key "fugubsd-1-release" \{\n\tstatus = retired\n/,
		'the old key retires' );
	like( $rc, qr/\tuntil  = \d{4}-\d\d-\d\d\n/,
		'and it takes an until date' );
	like( $rc, qr/key "fugubsd-2-release" \{\n\tstatus = current\n/,
		'the next key becomes current' );

	ok( verified( $root, 'fugubsd-2-release.pub' ),
		'the new current key signs the manifest' );
	ok( !verified( $root, 'fugubsd-1-release.pub' ),
		'and the retired key does not' );

	# A retired key stays published, so a release that it signed
	# still verifies.
	ok( -f "$root/web/keys/fugubsd-1-release.pub",
		'the retired key file stays' );
};

subtest 'a promote with no next key fails' => sub {
	my @cmd = (
		$^X,       $SCRIPT,   '--root', $root,
		'--step',  'promote', '--purpose', 'release',
		'--secret', $two
	);
	my $out = `@{[ join ' ', map { qq{'$_'} } @cmd ]} 2>&1`;

	isnt( $?, 0, 'the script fails' );
	like( $out, qr/holds no next key/, 'and it names the cause' );
};

subtest 'a description with no keys block fails' => sub {
	my $bare = tempdir( CLEANUP => 1 );
	open my $fh, '>', "$bare/.fuguwebrc" or die "Cannot write: $!";
	print {$fh} "site = Example\n";
	close $fh;

	my @cmd = (
		$^X,       $SCRIPT, '--root', $bare,
		'--step',  'mint',  '--purpose', 'release',
		'--secret', "$bare/x.sec"
	);
	my $out = `@{[ join ' ', map { qq{'$_'} } @cmd ]} 2>&1`;

	isnt( $?, 0, 'the script fails' );
	like( $out, qr/holds no keys block/, 'and it names the cause' );
};

subtest 'the first run writes the keys block itself' => sub {
	my $bare = tempdir( CLEANUP => 1 );
	open my $fh, '>', "$bare/.fuguwebrc" or die "Cannot write: $!";
	print {$fh} "site = Example\n";
	close $fh;

	# The first key of a site arrives with the block that
	# describes it. A block that landed first would name a
	# directory with no key and no manifest, and every build would
	# fail until the key arrived.
	my $made = rotate(
		$bare,     '--step',  'mint', '--purpose',
		'release', '--secret', "$bare/first.sec",
		'--org',   'fugubsd'
	) or return;

	is( $made->{name}, 'fugubsd-1-release.pub', 'the key is minted' );

	my $rc = slurp("$bare/.fuguwebrc");
	like( $rc, qr/keys "keys" \{\n\torg = fugubsd\n/,
		'the description holds the keys block' );
	like( $rc, qr/key "fugubsd-1-release" \{/,
		'and the key block beside it' );

	ok( -f "$bare/web/keys/fugubsd-1-release.pub", 'the key file exists' );
	ok( -f "$bare/web/keys/SHA256",     'and the manifest' );
	ok( -f "$bare/web/keys/SHA256.sig", 'and its signature' );

	# A second run must leave the block that the first one wrote.
	my $again = rotate(
		$bare,     '--step',  'mint', '--purpose',
		'release', '--secret', "$bare/second.sec",
		'--signer', "$bare/first.sec", '--org', 'fugubsd'
	) or return;

	is( $again->{serial}, 2, 'a second run adds one to the serial' );
	is( ( () = slurp("$bare/.fuguwebrc") =~ /^keys /mg ),
		1, 'and it writes no second keys block' );
};

done_testing();
