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
#内容还原
x=`cat $SecretFile`
recordnum=1
while [[ 1 == 1 ]]; do
	record=`echo $x|cut -d "|" -f$recordnum`
	if [[ -z $record ]]
	then
		break
	fi
	record1=`echo $record|cut -d ":" -f1`
	echo "原项:"$record1
	record2=`echo $record|cut -d ":" -f2`
	echo "加密项:"$record2
	#若项目中加密项与密钥文件的加密项不符合则退出程序
	searchresult=`grep $record2 -rl $ProjectPath`
	if [[ -z $searchresult ]]; then
		echo "指定的密钥文件不能还原"
		exit
	fi
	#替换文件夹中所有文件的内容（支持正则）
	#单引号不能扩展
sed -i '' "s/${record2}/${record1}/g" $searchresult
echo "第"$recordnum"项混淆代码还原完毕"
let "recordnum = $recordnum + 1"
done
#文件还原
filerecordnum=1
while [[ 1 == 1 ]]; do
	filerecord=`echo $x|cut -d "|" -f$filerecordnum`
	if [[ -z $filerecord ]]
	then
		break
	fi
	filerecord1=`echo $filerecord|cut -d ":" -f1`
	#echo "原项:"$filerecord1
	filerecord2=`echo $filerecord|cut -d ":" -f2`
	#echo "加密项:"$filerecord2
	#改文件名

	find $ProjectPath -name $filerecord2"*"| awk '
	BEGIN{
		frecord1="'"$filerecord1"'";
		frecord2="'"$filerecord2"'";
		finish=1;
	}
	{
		filestr=$0;
		gsub(frecord2,frecord1,filestr);
		print "mv " $0 " "filestr ";echo 第"finish"个混淆文件还原完毕"
		finish++;
	}'|bash
let "filerecordnum = $filerecordnum + 1"
done


