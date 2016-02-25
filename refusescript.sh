#!/bin/sh 
############################################################
#
#
#  代码混淆脚本  RyoHo 2016.2.25
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
SecretFile="/Users/RyoHo/Desktop/secret/rlf"$(date +%Y%m%d)"_"$(date +%H%M)
##############################################################################
echo  > $SecretFile
#查找文本中所有要求混淆的属性\方法\类
x=$(awk  '
	BEGIN{srand();k=0;}
#随机数生成函数
function random_int(min, max) {
    return int( rand()*(max-min+1) ) + min;
}
#随机字符串生成函数
function random_string(len) {
	result="UCS"k;
	alpbetnum=split("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,\
		A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z", alpbet, ",");
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
}' `grep 'ob_[A-Za-z0-9_]*_fus' -rl $ProjectPath` )
#加密对写入密钥文件
echo $x > $SecretFile

recordnum=1
while [ 1 == 1 ]; do
	record=`echo $x|cut -d "|" -f$recordnum`
	echo $record
	if [[ -z $record ]]
	then
		break
	fi
	record1=`echo $record|cut -d ":" -f1`
	echo "record1:"$record1
	record2=`echo $record|cut -d ":" -f2`
	echo "record2:"$record2
	#替换文件夹中所有文件的内容（支持正则）
	#单引号不能扩展
sed -i '' "s/${record1}/${record2}/g" `grep $record1 -rl $ProjectPath`
let "recordnum = $recordnum + 1"
echo $recordnum
done

#查找需要混淆的文件名并替换
filerecordnum=1
while [ 1 == 1 ]; do
	filerecord=`echo $x|cut -d "|" -f$filerecordnum`
	echo $filerecord
	if [[ -z $filerecord ]]
	then
		break
	fi
	filerecord1=`echo $filerecord|cut -d ":" -f1`
	echo "filerecord1:"$filerecord1
	filerecord2=`echo $filerecord|cut -d ":" -f2`
	echo "filerecord2:"$filerecord2
	#改文件名
	find $ProjectPath -name $filerecord1"*"| awk 'BEGIN{}{
		filestr=$0;
		frecord1="'"$filerecord1"'"
		frecord2="'"$filerecord2"'"
		gsub(frecord1,frecord2,filestr);
		print "mv " $0 " " filestr;
	}'|bash
let "filerecordnum = $filerecordnum + 1"
echo $filerecordnum
done
