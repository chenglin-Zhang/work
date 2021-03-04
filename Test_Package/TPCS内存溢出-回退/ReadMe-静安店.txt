更新时间：2020/12/30

更新门店：静安店

值守人员：顾祥龙

升级文件放置目录：\\shhsp005.aisino-wincor.com\PR\CustomerProjects\C60_ALDI\02_Build\16_安装包\60_服务部更新包\PATCH_V3.3.0

1.更新包: 
	TPDotnetSetupTPCS.ALDI.PATCH__V3.3.0-x86.msi
	
2.回滚方案
	备份文件：
	1）\\TPDotnet\bin\TPDotnet.WebServices.TPChannelServices.TPChannelServicesHostApp.exe
				

3.更新步骤:
	BackStore Service安装
	1）TPDotnetSetupTPCS.ALDI.PATCH__V3.3.0-x86.msi
	
	重启交通灯

4.日结前：否


5.BackStore Service：是    BackStore Client：否     POS：否     Windows SCO：否 	txCollector：否	    Android SCO：否


6.更新文件版本号:
	1）\\TPDotnet\bin\TPDotnet.WebServices.TPChannelServices.TPChannelServicesHostApp.exe 		6.0.77.2

7.本次更新内容:
	1）修复TPCS内存溢出问题

8.更新后验证:
	1）TPDotnet.WebServices.TPChannelServices.TPChannelServicesHostApp.exe
	2）检查该服务是否在资源管理器中正常使用

9.特殊操作(如有必要):
可选


