pkg_name=inspec-profile-linux-baseline
pkg_version=2.2.2
pkg_origin=nigelwright
pkg_deps=(chef/inspec)
pkg_license='Apache-2.0'

do_setup_environment() {
  ARCHIVE_PATH="$HAB_CACHE_SRC_PATH/$pkg_dirname/$pkg_name-$pkg_version.tar.gz"
}

do_build() {
  if [ ! -f $PLAN_CONTEXT/../inspec.yml ]; then
    exit_with 'Cannot find inspec.yml. Please build from profile root.' 1
  fi

  local profile_files=($(ls $PLAN_CONTEXT/../ -I habitat -I results))
  local profile_location="$HAB_CACHE_SRC_PATH/$pkg_dirname/build"
  mkdir -p $profile_location

  build_line "Copying profile files to $profile_location"
  cd $PLAN_CONTEXT/../ && cp -R ${profile_files[@]} $profile_location

  build_line "Archiving $ARCHIVE_PATH"
  inspec archive "$HAB_CACHE_SRC_PATH/$pkg_dirname/build"                            -o $ARCHIVE_PATH                            --overwrite
}

do_install() {
  mkdir -p $pkg_prefix/profiles
  cp $ARCHIVE_PATH $pkg_prefix/profiles
}
