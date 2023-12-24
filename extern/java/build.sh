for folder in $(ls -d */)
do
    echo "[java] Building $folder"
    cd $folder
    ./build.sh
    cd ..
done