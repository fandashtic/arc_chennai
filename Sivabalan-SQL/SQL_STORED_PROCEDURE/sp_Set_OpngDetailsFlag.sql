CREATE Procedure sp_Set_OpngDetailsFlag
As
Begin
--Create Table tempdb..OpeningDetails(SNo int)
--Update Setup Set UpdOpgDtlComplete = 1
If exists(Select * From SysObjects Where xtype = 'U' And Name = 'Batch_Products_Copy')
	Drop Table Batch_Products_Copy
If exists(Select * From SysObjects Where xtype = 'U' And Name = 'VanStatementAbstract_Copy')
	Drop Table VanStatementAbstract_Copy
If exists(Select * From SysObjects Where xtype = 'U' And Name = 'VanStatementDetail_Copy')
	Drop Table VanStatementDetail_Copy
Select * Into Batch_Products_Copy From Batch_Products
Select * Into VanStatementAbstract_Copy From VanStatementAbstract 
Select * Into VanStatementDetail_Copy From VanStatementDetail

--Refresh SchemeProducts 
Truncate Table SchemeProducts
Exec Sp_Insert_SchSKUDetail

--If (select Flag from tbl_mERP_ConfigAbstract Where ScreenCode = 'MarginInsertByFSU' and ScreenName ='MarginInsertByFSU') = 1 Or
--   (select Flag from tbl_mERP_ConfigAbstract Where ScreenCode = 'BPChannelPTRByFSU' and ScreenName ='BPChannelPTRByFSU') = 1
--Begin
--	Exec sp_MarginInsertByFSU
--End
	
End
