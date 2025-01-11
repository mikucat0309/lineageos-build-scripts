#!/usr/bin/env bash
set -e

git config --global user.name "$USER_NAME"
git config --global user.email "$USER_MAIL"

branch=$BRANCH_NAME
branch_dir=${branch//[^[:alnum:]]/_}
branch_dir=${branch_dir^^}
source_dir="$SRC_DIR/$branch_dir"
mkdir -p "$source_dir"
cd "$SRC_DIR/$branch_dir"

mkdir -p .repo/local_manifests
rsync -a --delete --include '*.xml' --exclude '*' "$LMANIFEST_DIR/" .repo/local_manifests/

repo init -u https://github.com/LineageOS/android.git \
  -b "$branch" --git-lfs -c --depth=1
time repo sync -c --fail-fast --force-checkout --verbose

cd "$SRC_DIR/$branch_dir/vendor/lineage"
curl -sSL https://github.com/OnePlus12R-development/android_vendor_lineage/commit/4085774f384fea04b2e4e5248ce08e87abbed125.patch | git am
