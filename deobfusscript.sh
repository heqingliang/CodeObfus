#!/bin/sh 
############################################################
#
#
#  代码还原脚本  RyoHo 2016.2.25
#
#
############################################################
#识别含有多字节编码字符时遇到的解析冲突问题
export LC_CTYPE=C 
export LANG=C
#配置项：
#项目路径
ProjectPath="/Users/RyoHo/Desktop/confuseTestProject"
#替换文本存放路径（不能在项目目录或其子目录）
SecretFile="/Users/RyoHo/Desktop/secret/rlf20160225_1406"
#第一个参数为项目路径
if [[ $1 ]]
then
if [[ $1 != "_" ]]; then
	ProjectPath=$1
fi
fi
#第二个参数指定密钥文件路径及文件名
if [[ $2 ]]
then
if [[ $2 != "_" ]]; then
	SecretFile=$2
fi
fi
##############################################################################

