export BASE_PATH=$(cd `dirname $0`;pwd)
export ROOT_PATH=$BASE_PATH/../
# ready to dir
rm -rf $BASE_PATH/dist/**
mkdir $BASE_PATH/dist
mkdir $BASE_PATH/dist/assets
mkdir $BASE_PATH/dist/chat-want-to-say
mkdir $BASE_PATH/dist/birth-want-to-say
cp $BASE_PATH/index.html $BASE_PATH/dist/
cp $BASE_PATH/assets/** $BASE_PATH/dist/assets/
# build chat want to say
sh $ROOT_PATH/chat-want-to-say/bin/build.sh preview
cp -r $ROOT_PATH/chat-want-to-say/dist/** $BASE_PATH/dist/chat-want-to-say/
# build birth want to say
cp -r $ROOT_PATH/birth-want-to-say/** $BASE_PATH/dist/birth-want-to-say/