CREATE Procedure sp_acc_rpt_ser_ServiceInvoiceSubDetail(@DocRef Int,@Info nVarChar(4000))  
As                              
Declare @ParamSep nVarchar(10)                                  
Declare @TempString nVarchar(4000)  
Declare @ParamSepCounter int  
Declare @ProductCode nVarChar(50)  
Declare @ItemSpec nVarChar(255)  
Declare @Type nVarChar(50)  
Declare @Prefix as nVarChar(10)  
  
Set @TempString = @Info  
Set @ParamSep = Char(2)  
                              
Set @ParamSepCounter = CHARINDEX(@ParamSep,@TempString,1)                                  
Set @ProductCode = SubString(@TempString,1,@ParamSepCounter - 1)  
              
Set @TempString = SubString(@TempString,@ParamSepCounter + 1,Len(@Info))  
Set @ParamSepCounter = CHARINDEX(@ParamSep,@TempString,1)                              
Set @ItemSpec = SubString(@TempString,1, @ParamSepCounter - 1)  
                            
Set @TempString = SubString(@TempString,@ParamSepCounter + 1, Len(@Info))  
set @Type = @TempString  
  
If @Type = N'2'  
 Begin                              
  Select 'TaskID'=SID.TaskID,'Task Description'=TaskMaster.[Description],  
  'Type'=Case IsNULL(TaskType,N'') When 0 Then dbo.LookupDictionaryItem('New',Default) When 1 Then dbo.LookupDictionaryItem('Bounce Case',Default) Else '' End,  
  'Estimated Rate'=IsNULL(EstimatedPrice,0),'Task Rate'=IsNULL(SID.Price,0),  
  'Service Tax(%)'=IsNULL(ServiceTax_Percentage,0),'Tax Amount'=IsNULL(SID.ServiceTax,0),  
  'Amount'=IsNULL(Amount,0),'Net Value'=IsNULL(Sum(Netvalue),0),'HighLight'=5  
  from ServiceInvoiceDetail SID,TaskMaster Where Type=@Type  
  And SID.Product_Code=@ProductCode And ServiceInvoiceID=@DocRef  
  And Product_Specification1=@ItemSpec And SID.TaskID = Taskmaster.TaskID  
  And IsNULL(SID.TaskID,N'')<>N'' and IsNULL(SpareCode,N'')=N''  
  Group By SID.TaskID,Taskmaster.[Description],SID.TaskType,SID.EstimatedPrice,  
  SID.Price,SID.ServiceTax_Percentage,SID.ServiceTax,SID.Amount  
 End                         
Else If @Type = N'3'                              
 Begin                              
  Select @Prefix=Prefix from VoucherPrefix where TranID = N'ISSUESPARES'  
  Select 'IssueID'=@Prefix + Cast(IssueAbstract.DocumentID as nvarchar(15)),  
  'Issue Date'=IssueAbstract.IssueDate,'Spare Code'=SID.SpareCode,'Spare Name'=ProductName,  
  'Batch'=SID.Batch_Number,'Qty'=IsNULL(SID.UOMQty,0),'Date of Sale'=SID.DateOfSale,  
  'Warranty'=Case IsNULL(SID.Warranty,0) When 1 Then dbo.LookupDictionaryItem('Yes',Default) When 2 Then dbo.LookupDictionaryItem('No',Default) Else '' End,  
  'Warranty No'=SID.WarrantyNo,'Sale Price'=IsNULL(SID.Price,0),'Amount'=IsNULL(SID.Amount,0),  
  'Discount(%)'=IsNULL(ItemDiscountPercentage,0),'SalesTax(%)'=IsNULL(SID.SaleTax,0),  
  'Tax Amount'=IsNULL(LstPayable,0) + IsNULL(CSTPayable,0),'TaxSuffered(%)'=IsNULL(SID.Tax_SufferedPercentage,0),  
  'TaxSuffered'=IsNULL(SID.TaxSuffered,0),'Type'=Case IsNULL(SID.SaleID,0) When 1 Then   
  'First Sale' When 2 then 'Second Sale' Else '' End,'Net Value'=IsNULL((Netvalue),0),'HighLight'=5  
  from ServiceInvoiceDetail SID,Items,IssueAbstract Where SID.ServiceInvoiceID=@DocRef  
  And SID.IssueID=IssueAbstract.IssueID And SID.Product_Code=@ProductCode And IsNULL(SpareCode,N'')<>N''  
  And SID.Product_specification1=@ItemSpec And SID.SpareCode=Items.Product_Code  
  Order by SerialNo                            
End 
