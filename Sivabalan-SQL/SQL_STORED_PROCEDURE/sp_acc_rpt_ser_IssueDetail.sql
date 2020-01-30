CREATE Procedure [dbo].[sp_acc_rpt_ser_IssueDetail](@IssueID INT,@DocType INT)
As                              
DECLARE @ISSUE_SPARES INT
DECLARE @ISSUE_SPARES_CANCEL INT
DECLARE @ISSUE_SPARES_RETURN INT
DECLARE @ItemSpec nVarChar(50)                               
DECLARE @TableSQL nvarchar(4000)                             
    
Set @ISSUE_SPARES=85            
Set @ISSUE_SPARES_CANCEL=86            
Set @ISSUE_SPARES_RETURN=87            

Select @ItemSpec=ServiceCaption from ServiceSetting where ServiceCode=dbo.LookupDictionaryItem('Itemspec1',Default)    
------------------------------Create a Dynamic Table-----------------------------------------    
CREATE Table #TempIssueDetail ([Item Code] nVarChar(50),[Item Name] nVarChar(255))    
Set @TableSQL=N'Alter table #TempIssueDetail     
Add [' + @ItemSpec + N'] nVarChar(50) NULL,[Color] nVarChar(50) NULL,[Inspected By] nVarChar(255) NULL,    
[Spare Code] nVarChar(50),[Spare Name] nVarChar(255),[Batch] nVarChar(128),UOM nVarChar(255),    
Qty Decimal(18,2),[Returned Qty] Decimal(18,2),[Net Qty] Decimal(18,2),[Date of Sale] DateTime,    
[Warranty] VarChar(10),[Warranty No] nVarChar(50),[Purchase Price] Decimal(18,6),HighLight INT'    
Exec sp_executesql @TableSQL    
---------------------------------------------------------------------------------------------                        
If @DocType=@ISSUE_SPARES Or @DocType=@ISSUE_SPARES_CANCEL
 Begin
  Insert Into #TempIssueDetail    
  Select I.Product_Code,ProductName,I.Product_Specification1,'Color'=(Select GM.[Description] From
  GeneralMaster GM,JobCardAbstract JCA,JobCardDetail JCD,ItemInformation_Transactions IIT,IssueAbstract IA
  Where IA.IssueID=@IssueID And IA.JobCardID=JCA.JobCardID And JCA.JobCardID=JCD.JobCardID
  And JCD.Type=0 And JCD.SerialNo=IIT.DocumentID And IIT.DocumentType=2 And IIT.Color=GM.Code),
  IsNULL(PersonnelMaster.PersonnelName,N''),I.SpareCode,'Spare Name'=(Select ProductName from     
  Items Where Items.Product_Code=I.SpareCode),IsNULL(Batch_Number,N''),'UOM'=UOM.[Description],    
  IsNULL(IssuedQty,0),IsNULL(ReturnedQty,0),IsNULL(IssuedQty,0)-IsNULL(ReturnedQty,0),    
  I.DateofSale,Case Isnull(Warranty,0) When 1 Then dbo.LookupDictionaryItem('Yes',Default) When 2 Then dbo.LookupDictionaryItem('No',Default) Else '' End,    
  IsNULL(WarrantyNo,N''),IsNULL(PurchasePrice,0),5 
  from IssueDetail I
  Inner Join Items on I.Product_Code=Items.Product_Code
  Inner Join UOM on I.UOM=UOM.UOM
  Left Outer Join  PersonnelMaster on I.PersonnelID = PersonnelMaster.PersonnelID
  Where 
  --I.Product_Code=Items.Product_Code 
  --And I.UOM=UOM.UOM 
  --And I.PersonnelID*=PersonnelMaster.PersonnelID 
  --And 
  I.IssueID=@IssueID    
 End
Else If @DocType=@ISSUE_SPARES_RETURN
 Begin
  Insert Into #TempIssueDetail    
  Select I.Product_Code,ProductName,I.Product_Specification1,'Color'=(Select GM.[Description] From
  GeneralMaster GM,JobCardAbstract JCA,JobCardDetail JCD,ItemInformation_Transactions IIT,IssueAbstract IA
  Where IA.IssueID=I.IssueID And IA.JobCardID=JCA.JobCardID And JCA.JobCardID=JCD.JobCardID
  And JCD.Type=0 And JCD.SerialNo=IIT.DocumentID And IIT.DocumentType=2 And IIT.Color=GM.Code),
  IsNULL(PersonnelMaster.PersonnelName,N''),I.SpareCode,'Spare Name'=(Select ProductName from     
  Items Where Items.Product_Code=I.SpareCode),IsNULL(Batch_Number,N''),'UOM'=UOM.[Description],    
  IsNULL(IssuedQty,0),IsNULL(ReturnedQty,0),IsNULL(IssuedQty,0)-IsNULL(ReturnedQty,0),    
  I.DateofSale,Case Isnull(Warranty,0) When 1 Then dbo.LookupDictionaryItem('Yes',Default) When 2 Then dbo.LookupDictionaryItem('No',Default) Else '' End,    
  IsNULL(WarrantyNo,N''),IsNULL(PurchasePrice,0),5 
  from IssueDetail I
  Inner Join Items on I.Product_Code=Items.Product_Code
  Inner Join UOM on I.UOM=UOM.UOM
  Left Outer Join PersonnelMaster on I.PersonnelID = PersonnelMaster.PersonnelID
  Inner Join SparesReturnInfo on SparesReturnInfo.SerialNo=I.SerialNo
  Where 
  --I.Product_Code=Items.Product_Code 
  --And I.UOM=UOM.UOM 
  --And I.PersonnelID*=PersonnelMaster.PersonnelID
  --And SparesReturnInfo.SerialNo=I.SerialNo And 
  SparesReturnInfo.TransactionID=@IssueID
 End

Select * from #TempIssueDetail    
Drop Table #TempIssueDetail
