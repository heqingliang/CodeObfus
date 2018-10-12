<h2>CodeObfus</h2>

<h3>introduction</h3>
Simple Shell script which can Obfuscate Code before pack, use for App, especially for iOS project. 

<h3>usage</h3>
Change the property or method name <b>AAA</b> as <b>ob_AAA_fus</b> and run script <b>obfusscript.sh</b> to obfuscate in the project.
Run script <b>deobfusscript.sh</b> to retore.

You need to set these path Before running script.
<h5>
#项目路径
ProjectPath="/Users/RyoHo/Desktop/confuseTestProject"
#替换文本存放路径（不能在项目目录或其子目录）
SecretFile="/Users/RyoHo/Desktop/secret/rlf"$(date +%Y%m%d)"_"$(date +%H%M)
</h5>
