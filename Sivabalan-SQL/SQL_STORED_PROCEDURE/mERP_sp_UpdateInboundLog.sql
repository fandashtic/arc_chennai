Create Procedure mERP_sp_UpdateInboundLog(@RecCnt Int,@SyncStart Datetime,@SynEnd Datetime)
As
Begin
	EXECUTE AS login = N'itcuser'
	Insert Into Inbound_Log(ApplicationName,Date,Remarks,NoOfOrders,NoOfCollections,NoOfSalesReturn,
							SyncStartTime,SyncEndTime)
	Values('EI',GetDate(),'ERP - Order Import',@RecCnt,0,0,@SyncStart,@SynEnd)
End
