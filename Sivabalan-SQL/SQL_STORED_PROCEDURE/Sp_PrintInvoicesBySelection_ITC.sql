Create Procedure Sp_PrintInvoicesBySelection_ITC  
(    
@InvoiceID NVarchar(Max)  
)    
As     
Create Table #TempInvoice(IDs int identity(1,1),InvoiceID Int)        
  
Insert InTo #TempInvoice (InvoiceID) Select * From sp_SplitIn2Rows(@InvoiceID,N',')         
  
Select IA.InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)  ,   IT.IDs
From InvoiceAbstract IA, VoucherPrefix   ,#TempInVoice IT
Where IT.Invoiceid=IA.InvoiceID --In (Select InvoiceID From #TempInvoice)      
And IA.InvoiceType in (1, 3)     
--And InvoiceAbstract.Status & 128 = 0             
And VoucherPrefix.TranID = N'INVOICE'           
order by IT.IDs Desc

