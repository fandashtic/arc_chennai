CREATE Proc sp_getSCforInvAmend(@InvNo Int)       
As    
Create table   #TempSO(SONumber Int)    
Declare @SONumber nVarchar(2000)      
Select  @SONumber = SONumber From InvoiceAbstract Where InvoiceID = @InvNo      
Insert into #TempSO select * from dbo.sp_Splitin2Rows(@SONumber,',')    
  
Select SOAbs.DocSerialType, SOAbs.SONumber, SOAbs.SODate, SV.DocumentID, ISNull(#TempSO.SoNumber,0)  
From InvoiceAbstract InvAbs, SOAbstract SOAbs, #TempSO, SVAbstract SV      
Where InvAbs.InvoiceID = @InvNo  
And SOAbs.SalesVisitNumber = SV.SVNumber
And InvAbs.CustomerID = SOAbs.CustomerID      
And InvAbs.SalesManID = SOAbs.SalesManID      
And SOAbs.SONumber = #TempSO.SONumber    
Union   
Select SOAbs.DocSerialType, SOAbs.SONumber, SOAbs.SODate, SV.DocumentID, 0 as TSONumber  
FROM InvoiceAbstract InvAbs, SOAbstract SOAbs, SVAbstract SV  
Where (SOAbs.Status & 192) = 0
And InvAbs.InvoiceID = @InvNo  
And InvAbs.CustomerID = SOAbs.CustomerID      
And InvAbs.SalesManID = SOAbs.SalesManID   
And SOAbs.SalesVisitNumber = SV.SVNumber
And SOAbs.SONumber Not in (Select SONumber From #TempSO)  
ORDER BY SOAbs.SONumber  
  
Drop Table #TempSO


