#!/bin/sh 
############################################################
#
#
#  代码混淆脚本  RyoHo 2016.2.25
#  .git/.svn文件夹不替换 
#
############################################################
#识别含有多字节编码字符时遇到的解析冲突问题
export LC_CTYPE=C 
export LANG=C
#配置项：
#项目路径
ProjectPath="/Users/RyoHo/Desktop/jiami_ob"
SecretfilePath="/Users/RyoHo/jiami_ob_secret/secret"
#秘密目录不能是项目目录子目录
if [[ `echo $SecretfilePath|grep $ProjectPath` ]]; then
	echo "秘密路径不能是项目路径的子目录"
	exit
fi
if [ ! -x $SecretfilePath ]; then
mkdir -p $SecretfilePath
fi
#不存在秘密目录则创建
if [ ! -x $SecretfilePath ]; then
mkdir -p $SecretfilePath
fi
#替换文本存放路径（不能在项目目录或其子目录）
SecretFile=$SecretfilePath"/rlf"$(date +%Y%m%d)"_"$(date +%H%M)

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

#查找文本中所有要求混淆的属性\方法\类
resultfiles=`grep --exclude-dir=".svn" \
--exclude-dir=".git" 'ob_[A-Za-z0-9_]*_fus' -rl $ProjectPath`
#查找结果为空则退出
if [[ -z $resultfiles ]]
then
	echo "项目没有需要混淆的代码"
	exit
else 
	echo "开始混淆代码..."
	echo  > $SecretFile
fi

x=$(awk  '
	BEGIN{srand();k=0;}
#随机数生成函数
function random_int(min, max) {
    return int( rand()*(max-min+1) ) + min;
}
#随机字符串生成函数
function random_string(len) {
	result="UCS"k;
	alpbetnum=split("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z", alpbet, ",");
    for (i=0; i<len; i++) {
        result = result""alpbet[ random_int(1, alpbetnum) ];
    }
    return result;
}
/ob_[A-Za-z0-9_]*_fus/{
   x = $0;
   #匹配需要混淆的属性变量方法
   while (match(x, "ob_[A-Za-z0-9_]*_fus") > 0) {
   tempstr=substr(x, RSTART, RLENGTH);
   #判断是否有之前已经找过的重复字符串
   for ( i = 0; i < k; i++ ){
   	if (strarr[i] == tempstr){break;}
   }
   if(i<k){
   	#重复字符串，直接删除
   	x=substr(x, RSTART+RLENGTH);
   	 continue; 
   }else{
   	#不是重复字符串，添加到替换数组
   	strarr[k++]=tempstr;
   }
   randomstr=random_string(20);
   printf("%s:%s|", tempstr,randomstr);
   #替换随机字符串
   gsub(tempstr,randomstr, x);
   x = substr(x, RSTART+RLENGTH);
}
}' $resultfiles )

#加密对写入密钥文件
echo $x > $SecretFile

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
	#替换文件夹中所有文件的内容（支持正则）
	#单引号不能扩展
sed -i '' "s/${record1}/${record2}/g" `grep --exclude-dir=".svn" \
--exclude-dir=".git" $record1 -rl $ProjectPath`
echo "第"$recordnum"项混淆代码处理完毕"
let "recordnum = $recordnum + 1"
done

#查找需要混淆的文件名并替换
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

	find $ProjectPath -name $filerecord1"*"| awk '
	BEGIN{frecord1="'"$filerecord1"'";frecord2="'"$filerecord2"'";finish=1}
	{
		filestr=$0;
		gsub(frecord1,frecord2,filestr);
		print "mv " $0 " " filestr";echo 第"finish"个混淆文件处理完毕";
	    finish++;
	}'|bash
let "filerecordnum = $filerecordnum + 1"
done
