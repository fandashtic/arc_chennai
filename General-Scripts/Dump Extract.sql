--Exec SP_ARC_GetAllSales
--Exec SP_ARC_GetAllSalesReturn
--Exec SP_ARC_GetAllCollections
--Exec SP_ARC_GetAllDebitnote
--Exec SP_ARC_GetAllCreditnote

--Exec SP_ARC_CustomerOutstandingBreakup
Set Dateformat dmy

--select * from ReportData where node = 'Outstanding - Salesman Invoicewise'
--Exec sp_acc_rpt_list_SMCustomer_OutStanding_ITC '%','%','01-Apr-2019','29-Feb-2020'

--exec sp_acc_rpt_Salesmanwise_OutStanding '01-Apr-2019','29-Feb-2020'

--exec spr_Customerwise_Categorywise '%','%','%','01-Apr-2019','29-Feb-2020'

--exec sp_acc_rpt_list_SMCGICustomer_OutStanding_ITC_OCG '%','%','Operational','%','01-Apr-2019','29-Feb-2020'

--exec spr_List_Collection_DSWise_BeatWise_Abstract_ITC_OCG 'Operational','%','Division','%','%','%','%','01-Apr-2019','29-Feb-2020','01-Apr-2019','29-Feb-2020','%','%'

--exec spr_list_CollectionStatementReport_ITC '%','01-Apr-2019','29-Feb-2020','%','%'

--exec spr_DSwiseBeatwiseOutstanding '%','%'