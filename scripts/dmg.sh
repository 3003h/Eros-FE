#!/bin/zsh
# shellcheck disable=SC2034

echo $pub_output_path

dmg(){
  echo "hdiutil create -fs HFS+ -srcfolder $1 -volname $2 $3.dmg"
  hdiutil create -fs HFS+ -srcfolder "$1" -volname "$2" "$3.dmg"
}

version=$1

if [ $# -eq 0 ];
then
    echo "version empty"
    exit
fi

macos_temp_dir="macos_temp"
macos_temp_file_name="feh_$version"
maco_temp_path="${pub_output_path}/$macos_temp_dir";

version_dir="$pub_output_path/macos_$version";

temp_file_path="$maco_temp_path/$macos_temp_file_name"

echo $maco_temp_path
echo $version_dir

rm -rf $maco_temp_path
mkdir $maco_temp_path

rm -rf $version_dir
mkdir $version_dir

cp -a $macos_archiver_path $maco_temp_path

cd $version_dir || exit
echo "cd $version_dir"
dmg $maco_temp_path "fehviewer" $macos_temp_file_name