#!/bin/bash
#
# 构建脚本


base_dir=`pwd`
origin_file_name=index
adoc_file_name=${origin_file_name}.adoc
origin_html_file_name=${origin_file_name}-html.html
web_html_file_name=index.html
style_dir=assets/styles/

# 确保 asciidoctor 命令被安装
asciidoctor=`which asciidoctor`
if [ ! -n "$asciidoctor" ]; then
  gem install asciidoctor
  asciidoctor=`which asciidoctor`
fi

# 确保 wkhtmltopdf 命令被安装
# wkhtmltopdf=`which wkhtmltopdf`
# if [ ! -n `which wkhtmltopdf` ]; then
#   brew cask install wkhtmltopdf
#   wkhtmltopdf=`which wkhtmltopdf`
# fi

# 解决 Mac 与 Linux 中 sed 处理不统一的问题
gsed=`which sed`
if [[ `uname` == Darwin* ]]
then
  gsed=`which gsed`
fi

# 确保 cssnano 命令被安装
cssnano=`which cssnano`
if [ ! -n "$cssnano" ]; then
  npm install cssnano-cli --g --registry=https://registry.npm.taobao.org
  cssnano=`which cssnano`
fi

# 确保 html-minifier 命令被安装
htmlminifier=`which html-minifier`
if [ ! -n "$htmlminifier" ]; then
  npm install html-minifier -g --registry=https://registry.npm.taobao.org
  htmlminifier=`which html-minifier`
fi

rm -rf *.html *.pdf

## Web ###########

# Web
$asciidoctor -a toc=left -a stylesdir=$style_dir -a linkcss $adoc_file_name -o $origin_html_file_name

cd ./$style_dir


for f in `ls .`
do
  # 压缩 CSS
  $cssnano $f $f
  echo "compress $f"
done

cd $base_dir

# 把语法高亮提前
$gsed -i "s/<\/head>/<link rel=\"stylesheet\" href=\"assets\/styles\/coderay-asciidoctor.css\"><\/head>/" $origin_html_file_name

# 调整样式
# $gsed -i "s/<\/head>/<style>a{text-decoration:none;}.img_bk{text-align:center;}<\/style><\/head>/" $origin_html_file_name

# 替换 Font Awesome，(内置功能不能保证版本一致)
# $gsed -i "s/https:\/\/cdnjs.cloudflare.com\/ajax\/libs/\/\/cdn.bootcss.com/" $origin_html_file_name

# 替换 Google Fonts
# $gsed -i "s/https:\/\/fonts.googleapis.com/\/\/fonts.proxy.ustclug.org/" $origin_html_file_name

$htmlminifier -c html-minifier.config.json $origin_html_file_name -o $web_html_file_name

# cp $origin_html_file_name $web_html_file_name

echo "`date '+%Y-%m-%d %H:%M:%S'` build"

if [ -n "$1" ]; then
    # echo "start rsync..."

    # rsync -avz --exclude=".*" ./assets ./$web_html_file_name  deployer@notes.diguage.com:/home/deployer/diguage.com/notes/mysql
    
    # echo "`date '+%Y-%m-%d %H:%M:%S'` deploy"
    echo "start copy files..."
    cp -rf ./assets index.html $1 && echo "build note `basename $base_dir` success, output file is in $1"
fi