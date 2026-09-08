#!/usr/bin/env perl
# ex:ts=8 sw=4:
# Guards for .github/workflows/rotate-key.yml, per SITE-ROTATE
#
# The workflow holds the strongest credential of the organization, and
# it publishes key material. Nothing under .github/ runs outside a
# runner, so this test reads the workflow as text.
#
# The order of the steps is the design. A review panel reproduced the
# faults that a wrong order causes: an organization that names a key
# no consumer can fetch, and a published key whose private half no
# slot holds. Each guard below holds one of those faults out.

use v5.36;
use Test::More;
use FindBin qw($RealBin);

my $path = "$RealBin/../../.github/workflows/rotate-key.yml";

plan skip_all => 'no rotate-key workflow' unless -f $path;

open my $fh, '<', $path or die "cannot read $path: $!\n";
my $yml = do { local $/; <$fh> };
close $fh;

# _steps():
#	The step names, in the order that the file holds them.
sub _steps ()
{
	return $yml =~ /^      - name: (.+)$/mg;
}

# _at($name):
#	The position of one step, or undef.
sub _at ($name)
{
	my @steps = _steps();
	for my $i ( 0 .. $#steps ) {
		return $i if $steps[$i] eq $name;
	}

	return;
}

# _step($name):
#	The text of one step, from its name to the next step.
sub _step ($name)
{
	my ($block) =
	    $yml =~ /^      - name: \Q$name\E\n(.*?)(?=^      - name: |\z)/ms;

	return $block;
}

my @STEPS = _steps();

subtest 'the steps of a rotation stand in order' => sub {
	my %at = map { $STEPS[$_] => $_ } 0 .. $#STEPS;

	my @want = (
		'Refuse a purpose that this workflow cannot address',
		'Install the dependencies',
		'Install fuguweb',
		'Mint an installation token',
		'Run the rotation step',
		'Store the new private key',
		'Commit the key directory',
		'Publish the site',
		'Confirm the published site serves what this run wrote',
		'Name the active slot',
		'Declare the key in FuguBSD/Tooling',
	);

	for my $name (@want) {
		ok( defined $at{$name}, "the step '$name' is there" );
	}

	# SITE-ROTATE-15. Unpinned code must not run beside the App
	# credentials, so each install runs before the token.
	ok( $at{'Install fuguweb'} < $at{'Mint an installation token'},
		'each install runs before the token' );

	# The guard reaches no credential.
	ok(
		$at{'Refuse a purpose that this workflow cannot address'} <
		    $at{'Mint an installation token'},
		'the purpose guard runs before the token'
	);

	# SITE-ROTATE-23. No reader reaches the idle slot until the
	# variable names it, and a later write could publish a key
	# whose private half no slot holds.
	ok(
		$at{'Store the new private key'} <
		    $at{'Commit the key directory'},
		'the private key reaches its slot before the commit'
	);

	# SITE-ROTATE-18. The variable names the active slot, so it
	# moves only after the site serves what the run wrote.
	ok(
		$at{'Confirm the published site serves what this run wrote'} <
		    $at{'Name the active slot'},
		'the variable moves after the site serves the key'
	);
	ok(
		$at{'Commit the key directory'} < $at{'Publish the site'},
		'the publish follows the commit'
	);
	ok(
		$at{'Name the active slot'} <
		    $at{'Declare the key in FuguBSD/Tooling'},
		'and the declaration comes last'
	);
};

subtest 'the workflow can start the publish' => sub {

	# SITE-ROTATE-19. GitHub raises no workflow run from a push
	# that GITHUB_TOKEN makes, so the site never rebuilds by
	# itself. workflow_dispatch is the one event that the token
	# can raise, and it needs the actions grant.
	like( $yml, qr/^permissions:\n(?:  .*\n)*  actions: write$/m,
		'the job can write actions' );

	my $publish = _step('Publish the site');
	ok( $publish, 'the publish step is there' ) or return;

	like( $publish, qr/gh workflow run publish\.yml/,
		'it dispatches the publish' );

	# SITE-ROTATE-24. A run identifier is a race, because the
	# publish holds a concurrency group.
	unlike( $publish, qr/gh run (?:list|view|watch)/,
		'and it watches no run' );
};

subtest 'the workflow reads the site before it declares a key' => sub {
	my $confirm =
	    _step('Confirm the published site serves what this run wrote');
	ok( $confirm, 'the confirm step is there' ) or return;

	# SITE-ROTATE-20. A promote writes no key file, so the
	# manifest pair is what a promote changes.
	like( $confirm, qr/files="SHA256 SHA256\.sig"/,
		'it reads the manifest pair' );
	like( $confirm, qr/\[ "\$STEP" = mint \] && files="\$files \$NAME"/,
		'and the key file of a mint' );

	# A cache can answer 200 with older bytes.
	like( $confirm, qr/cmp -s/, 'it compares the bytes' );
	like( $confirm, qr/exit 1/, 'and it fails when the site differs' );
};

subtest 'the private key stays out of every log and command line' => sub {
	my $mask = _step('Mask the new private key');
	ok( $mask, 'the mask step is there' ) or return;
	like( $mask, qr/::add-mask::/, 'it masks each line of the key' );

	ok( _at('Mask the new private key') < _at('Store the new private key'),
		'and it runs before the key reaches a command' );

	# SITE-ROTATE-16. The body of a secret comes from a file, and
	# gh secret set takes it on standard input.
	my $store = _step('Store the new private key');
	ok( $store, 'the store step is there' ) or return;
	like( $store, qr/^\s*<\s*"\$WORK\/new\.sec"/m,
		'the secret comes in on standard input' );
	unlike( $store, qr/--body/, 'and never on a command line' );
};

subtest 'the secret reaches every repository that needs it' => sub {
	my $store = _step('Store the new private key');
	ok( $store, 'the store step is there' ) or return;

	my ($repos) = $store =~ /--repos (\S+)/;
	ok( $repos, 'the step names the repositories' ) or return;
	my %reads = map { $_ => 1 } split /,/, $repos;

	# SITE-ROTATE-2. This repository runs the workflow, so a list
	# that named the release callers alone would leave a later run
	# reading its own key secret as empty.
	ok( $reads{Website}, 'this repository reads the secret' );

	# Each repository that releases a Perl distribution signs with
	# the key, so each one reads it.
	ok( $reads{$_}, "and $_" ) for qw(Fugu FuguVM FuguWeb);

	# A repository that releases nothing must hold no private key.
	# It verifies with the published one, as every consumer does.
	ok( !$reads{FuguTTX}, 'and FuguTTX, which releases none, does not' );
};

subtest 'the declaration writes both copies of the key file' => sub {
	my $declare = _step('Declare the key in FuguBSD/Tooling');
	ok( $declare, 'the declare step is there' ) or return;

	# SITE-ROTATE-21. Tooling syncs the org pack into itself, so
	# one copy alone fails the drift gate of that pull request.
	like(
		$declare,
		qr{for keys in org/sync/deps/KEYS\.txt deps/KEYS\.txt},
		'it writes the canonical copy and the synced one'
	);

	# SITE-ROTATE-25. A second run of one step must open its own
	# pull request.
	like( $declare, qr/branch="keys\/\$STEM-mint-\$RUN"/,
		'the branch carries the run identifier' );

	# SITE-ROTATE-22. A promote must lift its line to the top, and
	# this workflow holds no such edit.
	like( $declare, qr/if: inputs\.step == 'mint'/m,
		'a mint is what opens the pull request' );
	my $refuse = _step('Refuse to declare a promote');
	ok( $refuse, 'and a promote stops with a reason' );
};

subtest 'the declaration can push its branch' => sub {
	my $declare = _step('Declare the key in FuguBSD/Tooling');
	ok( $declare, 'the declare step is there' ) or return;

	# SITE-ROTATE-26. gh repo clone leaves a remote that carries
	# no credential, and the push then asks for a username.
	like( $declare, qr/git config credential\.helper/,
		'the clone gets a credential helper' );

	# The helper must read the token when git runs it. A token
	# that the shell expands here would reach the config file.
	like( $declare, qr/'[^']*"password=\$GH_TOKEN"[^']*'/,
		'and the helper reads the token from the environment' );

	# The token must reach no command line and no remote URL.
	unlike( $declare, qr/x-access-token:/,
		'no remote URL carries the token' );
};

subtest 'the workflow serves one purpose, and it says so' => sub {

	# SITE-ROTATE-17. The secrets context cannot build a name from
	# an input, so a docs mint would write the release slot.
	my $guard = _step('Refuse a purpose that this workflow cannot address');
	ok( $guard, 'the guard is there' ) or return;

	like( $guard, qr/!= release/, 'it takes the release purpose alone' );
	like( $guard, qr/exit 1/,     'and it stops every other one' );
};

subtest 'each install names the version that it installs' => sub {

	# SITE-ROTATE-15. This job runs the installed code beside a
	# private key.
	my $install = _step('Install fuguweb');
	ok( $install, 'the install step is there' ) or return;

	unlike( $install, qr{releases/latest/download},
		'no install reads the latest release' );
	like( $install, qr/FUGU_VERSION: v\d+\.\d+\.\d+/,
		'the Fugu version is pinned' );
	like( $install, qr/FUGUWEB_VERSION: v\d+\.\d+\.\d+/,
		'and the FuguWeb version' );
};

done_testing();
