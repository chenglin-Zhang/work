1.更新包: 1）TPDotnetSetupBackstore.ALDI.PATCH__V1.3.0-x86.msi
	  2）TPDotnetSetupUpdateDatabase.ALDI.PATCH__V2.4.0-x86.msi

2.回滚方案
	替换备份文件和回滚SQL：
	\\shhsp005.aisino-wincor.com\PR\CustomerProjects\C60_ALDI\02_Build\16_安装包\60_服务部更新\PATCH_V2.4.0\rollback
	

3.更新步骤: 
	1)BSServer安装：TPDotnetSetupUpdateDatabase.ALDI.PATCH__V2.4.0-x86.msi
	2)BSServer和BSClient安装：TPDotnetSetupBackstore.ALDI.PATCH__V1.3.0-x86.msi
	
4.日结前：否

5.BackStore Service：是    BackStore Client：是     POS：否     Windows ACO：否 	txCollector：否


6.更新文件版本号:
	dll文件
	1)\\TPDotnet\bin\TPDotnet.ALDI.Backstore.Reporting.ReportViewerUnCountedStockTake.dll	6.0.77.4
	rpt文件
	2）TPALDIRetailStoreUnCountedStockTake.rpt  						128KB

7.本次更新内容:	
	1、新增 库存快照功能
	2、修复 Backstore未盘点报告在没有盘点数据时无法正常打开

8.更新后验证:
	


9.特殊操作(如有必要):
可选


