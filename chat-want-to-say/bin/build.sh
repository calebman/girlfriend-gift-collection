export BASE_PATH=$(cd `dirname $0`;pwd)
if [ ! $1 ]; then
    $1='production'
fi
# Build front with yarn.
cd $BASE_PATH/../
yarn
echo "yarn build --mode $1"
yarn build --mode $1