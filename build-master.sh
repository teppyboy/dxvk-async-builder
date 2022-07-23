#!/usr/bin/env bash

opt_nopackage=0
opt_devbuild=0
opt_deploy_web=0
opt_nobuild=0
opt_buildid=false

build_args="master ../build/ --no-package"

while [ $# -gt 0 ]; do
  case "$1" in
  "--no-package")
    opt_nopackage=1
    ;;
  "--dev-build")
    opt_nopackage=1
    opt_devbuild=1
    build_args+=" --dev-build"
    ;;
  "--build-id")
    opt_buildid=false
    build_args+=" --build-id"
    ;;
  "--no-build")
    opt_nobuild=1
    ;;
  "--deploy-web")
    opt_deploy_web=1
    ;;
  *)
    echo "Unrecognized option: $1" >&2
    exit 1
  esac
  shift
done

cd ./dxvk-async
echo "Updating DXVK-Async..."
git pull
dxvk_async_commit=$(git rev-parse --short HEAD)
dxvk_async_long_commit=$(git rev-parse HEAD)
dxvk_async_branch=$(git rev-parse --abbrev-ref HEAD)

cd ../dxvk/
echo "Reverting file changes (in case already patched with DXVK-Async)..."
git reset --hard
echo "Updating DXVK..."
git pull
dxvk_commit=$(git rev-parse --short HEAD)
dxvk_long_commit=$(git rev-parse HEAD)
dxvk_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Patching DXVK..."
git apply ../dxvk-async/dxvk-async.patch
git diff
echo "Building DXVK-Async... (args: $build_args)"
package_name="dxvk-async-git+$dxvk_commit-git+$dxvk_async_commit"
if [[ $opt_nobuild == 0 ]]; then
    ./package-release.sh $build_args
fi
cd "../build/"
mv "./dxvk-master" "./$package_name"
if [[ $opt_nopackage == 0 ]]; then
    echo "Packing..."
    tar -czf "$package_name.tar.gz" "./$package_name"
    sha256=$(sha256sum "$package_name.tar.gz" | cut -d " " -f 1)
    echo "SHA256: $sha256"
    if [[ $opt_deploy_web == 1 ]]; then
        echo "Setting DXVK url in webpage..."
        cp -r ../web ./web/
        cd ./web/
        mv index.html index.html.bak
        sed -e "s/{GIT_DXVK_BRANCH}/$dxvk_branch/g" -e "s/{GIT_DXVK_SHORT_COMMIT_HASH}/$dxvk_commit/g" -e "s/{GIT_DXVK_COMMIT_HASH}/$dxvk_long_commit/g" \
            -e "s/{GIT_DXVK_ASYNC_BRANCH}/$dxvk_async_branch/g" -e "s/{GIT_DXVK_ASYNC_SHORT_COMMIT_HASH}/$dxvk_async_commit/g" -e "s/{GIT_DXVK_ASYNC_COMMIT_HASH}/$dxvk_async_long_commit/g" \
            -e "s/{FILE_NAME}/$package_name.tar.gz/g" -e "s/{FILE_SHA}/$sha256/g" \
        index.html.bak > index.html

        mv dl.html dl.html.bak
        sed -e "s/{FILE_NAME}/$package_name.tar.gz/g" dl.html.bak > dl.html
        
        mv api/build.json api/build.json.bak
        sed -e "s/{GIT_DXVK_COMMIT_HASH}/$dxvk_long_commit/g" \
            -e "s/{GIT_DXVK_ASYNC_COMMIT_HASH}/$dxvk_async_long_commit/g" \
            -e "s/{FILE_NAME}/$package_name.tar.gz/g" -e "s/{FILE_SHA}/$sha256/g" \
        api/build.json.bak > api/build.json

        rm *.bak
        mkdir -p ./build/
        cp "../$package_name.tar.gz" "./build/$package_name.tar.gz"
    fi
fi
