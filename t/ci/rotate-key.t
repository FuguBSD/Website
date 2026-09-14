#!/usr/bin/env perl
# ex:ts=8 sw=4:
# Guards for .github/workflows/rotate-key.yml, per SITE-ROTATE
#
# The workflow is a thin caller of the reusable workflow of FuguWeb.
# The callee holds the order of the steps, and FuguWeb WEB-ACTIONS
# states each rule of it. This test holds what the caller owns: the
# pin of the callee, every input that the callee needs, the three
# keys that a called job cannot hold, and the pairing of each key
# directory with its own secrets.
#
# The pairing is the guard that matters most. A run that took the
# admin directory with the releng prefix would write a release key
# into an admin slot, and it would give that key to each repository
# of the releng list. Each value that a directory decides therefore
# comes from the directory input, and the test reads each one for
# both directories.
#
# Nothing under .github/ runs outside a runner, so the test reads the
# workflow as text.

use v5.36;
use Test::More;
use FindBin qw($RealBin);

my $path = "$RealBin/../../.github/workflows/rotate-key.yml";

plan skip_all => 'no rotate-key workflow' unless -f $path;

open my $fh, '<', $path or die "cannot read $path: $!\n";
my $yml = do { local $/; <$fh> };
close $fh;

# The reusable workflow that holds every step of a key rotation.
use constant CALLEE => 'FuguBSD/FuguWeb/.github/workflows/keys-rotate.yml';

# The dispatch inputs of the caller, per SITE-ROTATE-14. With no
# subordinate purposes input, a root promote binds no subordinate
# key, and the callee reports nothing.
my @DISPATCH = qw(
    step purpose type directory bootstrap subordinate_purposes email
    expires file
);

# The inputs that the callee declares as required. A call that omits
# one of them fails at the start of the run, with no key written.
my @REQUIRED = qw(
    step purpose directory org url environment secret_prefix owner
    publish_workflow
);

# Each value that the directory decides, for each directory. The org
# word leads every key name of the directory, and FuguWeb WEB-KEYS-2
# refuses two blocks that name one word. The secret prefix names the
# two key secrets, the variable and the App of the environment. The
# visibility list names each repository that reads the private key. A
# releng key reaches this site, and each repository that releases a
# Perl distribution. An admin key serves this site alone.
my %DERIVED = (
	releng => {
		directory     => 'web/releng',
		environment   => 'releng',
		url           => 'https://www.fugubsd.org/releng',
		org           => 'fugureleng',
		secret_prefix => 'RELENG',
		visibility    => 'Website,Fugu,FuguBench,FuguSeed,FuguVM,FuguWeb',
	},
	admin => {
		directory     => 'web/admin',
		environment   => 'admin',
		url           => 'https://www.fugubsd.org/admin',
		org           => 'fuguadmin',
		secret_prefix => 'ADMIN',
		visibility    => 'Website',
	},
);

# _slurp($path):
#	Whole file as text, or undef.
sub _slurp ($file)
{
	open my $in, '<', $file or return;
	my $text = do { local $/; <$in> };
	close $in;

	return $text;
}

# _with():
#	The with block of the call, as a name to value map. A value
#	that YAML folds over two lines joins with one space, as the
#	runner reads it.
sub _with ()
{
	my %with;
	my $name;
	my $in = 0;

	for my $line ( split /\n/, $yml ) {
		if ( $line =~ /^    with:\s*$/ ) {
			$in = 1;
			next;
		}
		next unless $in;

		# The block ends at the first line that stands outside
		# it. A comment line holds no value.
		last if $line !~ /^      \s*\S/;
		next if $line =~ /^\s*#/;

		if ( $line =~ /^      (\w+):\s*(.*?)\s*$/ ) {
			$name = $1;
			$with{$name} = $2;
			next;
		}

		if ( defined $name && $line =~ /^        \s*(.*?)\s*$/ ) {
			$with{$name} =
			    join q{ }, grep { length } $with{$name}, $1;
		}
	}

	return %with;
}

# _options($input):
#	The choice options of one dispatch input, in file order.
sub _options ($input)
{
	my ($block) = $yml =~
	    /^      \Q$input\E:\n(.*?)(?=^      \w+:|^\S|\z)/ms;
	return unless defined $block;

	return $block =~ /^\s+- (\S+)$/mg;
}

# _default($input):
#	The default value of one dispatch input, or undef.
sub _default ($input)
{
	my ($block) = $yml =~
	    /^      \Q$input\E:\n(.*?)(?=^      \w+:|^\S|\z)/ms;
	return unless defined $block;

	my ($value) = $block =~ /^\s+default:\s*(\S+)\s*$/m;

	return $value;
}

# _evaluate($value, $directory):
#	One with value, as the runner reads it for one directory. The
#	expression of a derived value is a test on the directory word,
#	the value that a true test takes, and the value that a false
#	test takes.
sub _evaluate ( $value, $directory )
{
	my $out = $value;

	$out =~ s{
	    \$\{\{\s*inputs\.directory\s*==\s*'(\w+)'
	    \s*&&\s*'([^']*)'\s*\|\|\s*'([^']*)'\s*\}\}
	}{$directory eq $1 ? $2 : $3}gex;

	$out =~ s{\$\{\{\s*inputs\.directory\s*\}\}}{$directory}g;

	return $out;
}

my %WITH = _with();

subtest 'the caller pins the callee to a commit' => sub {
	my @uses = $yml =~ /^\s*uses:\s*(\S+)\s*$/mg;
	is( scalar @uses, 1, 'the workflow calls one workflow' ) or return;

	my ( $ref, $pin ) = $uses[0] =~ /^(.*)\@(.*)$/;
	is( $ref, CALLEE, 'it calls the key workflow of FuguWeb' );

	# The callee runs beside a private key, so a tag or a branch
	# would let another commit reach that key. The pin below is
	# the commit of the v0.6.0 tag.
	like( $pin, qr/^[0-9a-f]{40}$/, 'and it pins a commit' );
};

subtest 'the caller passes every input that the callee requires' => sub {
	for my $name (@REQUIRED) {
		ok( length( $WITH{$name} // q{} ), "the call passes $name" );
	}

	# The callee holds no organization name and no domain, per
	# FuguWeb WEB-ACTIONS-9, so each one stands here. The org word
	# belongs to one directory, so the subtest below reads it.
	is( $WITH{owner}, 'FuguBSD', 'the owner is FuguBSD' );
	is( $WITH{publish_workflow},
		'publish.yml', 'and the callee starts publish.yml' );
};

subtest 'every dispatch input reaches the call' => sub {
	my ($inputs) = $yml =~ /^    inputs:\n(.*?)(?=^permissions:)/ms;
	ok( $inputs, 'the dispatch declares inputs' ) or return;

	my @names = $inputs =~ /^      (\w+):$/mg;
	ok( scalar @names, 'and the test reads each name' ) or return;

	is( join( q{ }, sort @names ), join( q{ }, sort @DISPATCH ),
		'the dispatch declares each input of SITE-ROTATE-14' );

	# Each input reaches the value of its own name. A test that
	# read the whole block would pass on a swap, and a swap of
	# email and expires would give gpg(1) an address that is a
	# date.
	for my $name (@names) {
		like( $WITH{$name} // q{}, qr/\binputs\.\Q$name\E\b/,
			"the $name value of the call reads the $name input" );
	}
};

subtest 'each directory takes its own secrets and its own URL' => sub {
	for my $directory ( sort keys %DERIVED ) {
		my $want = $DERIVED{$directory};
		for my $name ( sort keys %{$want} ) {
			is( _evaluate( $WITH{$name} // q{}, $directory ),
				$want->{$name},
				"$directory: $name is $want->{$name}" );
		}
	}
};

subtest 'the dispatch offers the two directories, and no other' => sub {

	# The derivation of a value holds two branches, so a third
	# word would take the values of the admin directory, and its
	# secrets with them.
	my @directories = _options('directory');
	is( join( q{ }, sort @directories ),
		'admin releng', 'the directory input takes the two words' );

	# The callee runs the verb of the step, which is mint-key,
	# import-key or promote-key.
	my @steps = _options('step');
	is( join( q{ }, sort @steps ),
		'import mint promote', 'and the step input takes the three verbs' );

	# SITE-ROTATE-14. A directory holds its root key first, per
	# SITE-KEYS-4. The default therefore names the root, and never
	# a subordinate key. A first mint of a directory that no keys
	# block names also needs the bootstrap flag, per FuguWeb
	# WEB-ROTATE-22, and that flag defaults to false.
	is( _default('purpose'), 'root', 'the purpose input defaults to root' );
};

subtest 'the caller holds what a called job cannot' => sub {

	# FuguWeb WEB-ACTIONS-14. permissions, concurrency and
	# secrets: inherit stay in the caller.
	my ($permissions) = $yml =~ /^permissions:\n((?:  .*\n|\s*#.*\n)+)/m;
	ok( $permissions, 'the caller holds the permissions' ) or return;

	# The callee commits the key directory and the description.
	like( $permissions, qr/^  contents: write$/m, 'the job can write the tree' );

	# The callee starts the publish itself, per FuguWeb
	# WEB-ACTIONS-8, because a push that GITHUB_TOKEN makes raises
	# no workflow run.
	like( $permissions, qr/^  actions: write$/m,
		'and it can start the publish' );

	# A second run beside the first would push the same
	# description from another tree.
	like( $yml, qr/^concurrency:\n(?:\s*#.*\n)*  group: \S+$/m,
		'the caller holds a concurrency group' );
	like( $yml, qr/^  cancel-in-progress: false$/m,
		'and no run cancels another' );

	# The callee reads each secret by a name that an input forms,
	# so the whole context must reach it.
	like( $yml, qr/^    secrets: inherit$/m, 'the call inherits the secrets' );
};

subtest 'the caller runs nothing of its own' => sub {

	# The caller holds no step. Each command of a rotation runs in
	# the callee, beside the private key, and FuguWeb WEB-ACTIONS
	# states every guard of it.
	unlike( $yml, qr/^\s*steps:$/m, 'the caller declares no step' );
	unlike( $yml, qr/^\s*run:/m,    'and it runs no command' );
};

subtest 'each install names the version that it installs' => sub {

	# SITE-ROTATE-15. The callee installs with make deps of this
	# repository, per FuguWeb WEB-ACTIONS-5, and it runs that code
	# beside a private key. The manifest therefore pins each
	# version, and a later release reaches no key before a human
	# reads the change.
	my $manifest = _slurp("$RealBin/../../deps/Linux.txt") // q{};
	ok( length $manifest, 'the manifest is there' ) or return;

	my @dists = $manifest =~ /^\s*runtime\s+dist\s+(\S+)$/mg;
	is( scalar @dists, 2, 'the manifest names two distributions' );

	for my $url (@dists) {
		unlike( $url, qr{releases/latest/download},
			"no install reads the latest release: $url" );
		like( $url, qr{releases/download/v\d+\.\d+\.\d+/},
			"the version is pinned: $url" );
	}

	like( join( q{ }, @dists ), qr{/FuguBSD/Fugu/}, 'Fugu is one of them' );
	like( join( q{ }, @dists ), qr{/FuguBSD/FuguWeb/},
		'and FuguWeb is the other' );
};

subtest 'the manifest installs the command of each signer' => sub {

	# SITE-ROTATE-31. Fugu::Signify runs signify(1) for each
	# private key operation, and Fugu::OpenPGP drives gpg(1) with
	# no other engine. A step that finds no command writes no key.
	for my $os (qw(Darwin Linux)) {
		my $manifest = _slurp("$RealBin/../../deps/$os.txt") // q{};
		ok( length $manifest, "the $os manifest is there" ) or next;

		like( $manifest, qr/^\s*tool\s+pkg\s+signify\S*$/m,
			"$os installs signify" );
		like( $manifest, qr/^\s*runtime\s+pkg\s+gnupg$/m,
			"$os installs gnupg" );
	}
};

subtest 'the digest file records each distribution' => sub {

	# SITE-ROTATE-32. scripts/deps reads a recorded digest before
	# the signify tier, so make deps of this repository reads no
	# published key, and a key step runs while the site serves no
	# key directory. A dist entry with no recorded digest falls to
	# that tier, and the key step then needs the site that it
	# writes. The test reads each manifest, so a later entry takes
	# the guard with it.
	my $dir  = "$RealBin/../../deps";
	my $sums = _slurp("$dir/SHA256.txt") // q{};
	ok( length $sums, 'the digest file is there' ) or return;

	opendir my $dh, $dir or die "cannot read $dir: $!\n";
	my @manifests = sort grep { /[.]txt\z/ } readdir $dh;
	closedir $dh;

	my @found;
	for my $manifest (@manifests) {
		my $text = _slurp("$dir/$manifest") // q{};
		push @found, $text =~ /^\s*\w+\s+dist\s+(\S+)\s*$/mg;
	}

	my %seen;
	my @dists = grep { !$seen{$_}++ } @found;
	ok( scalar @dists, 'the manifests name a distribution' ) or return;

	for my $url (@dists) {
		like( $sums, qr/^SHA256 [(]\Q$url\E[)] = [0-9a-f]{64}$/m,
			"the digest file records $url" );
	}
};

done_testing();
