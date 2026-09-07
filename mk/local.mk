# mk/local.mk: the consumer hook of this repository (MK-LOCAL).
# sync never touches this file.

# TEST_GLOBS: the org fragment covers t/ci/*.t. This repository also
# holds the test of scripts/rotate-key directly under t/.
TEST_GLOBS	= t/*.t t/ci/*.t
