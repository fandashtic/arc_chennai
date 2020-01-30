CREATE procedure sp_Print_VanStatementAbstract (@DocSerial int)  
as  
declare @ItemCount int  
Declare @OTHERS As NVarchar(50)  
  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
  
select @ItemCount=count(*)  
From VanStatementDetail
Left Outer Join Batch_Products  On VanStatementDetail.Product_Code = Batch_Products.Product_Code And VanStatementDetail.Batch_Code = Batch_Products.Batch_Code  
Inner Join  Items On VanStatementDetail.Product_Code = Items.Product_Code 
Where VanStatementDetail.DocSerial = @DocSerial

Select DocSerial,   
"DocumentNo" = DocumentID,   
"Date" = DocumentDate,   
"Salesman ID" = VanStatementAbstract.SalesmanID,  
"Salesman" = Salesman.Salesman_Name,   
"Beat ID" = IsNull(VanStatementAbstract.BeatID,0),   
"Beat" = IsNull(Beat.Description, @OTHERS),  
"Total Value" = VanStatementAbstract.DocumentValue,   
"Van ID" = VanStatementAbstract.VanID,   
"Van Number" = Van.Van_Number,  
"Status" = VanStatementAbstract.Status,  
"Loading Date" = VanStatementAbstract.LoadingDate,"Item Count" = @ItemCount,  
"Damaged Details" = Replace(Replace(dbo.fn_GetSalesReturnDamageFromVan(@DocSerial), N';', CHAR(9)), N':', CHAR(13) + CHAR(10))  
From VanStatementAbstract
Inner Join Van On VanStatementAbstract.VanID = Van.Van 
Inner Join  Salesman On VanStatementAbstract.SalesmanID = Salesman.SalesmanID 
Left Outer Join Beat On VanStatementAbstract.BeatID = Beat.BeatID
Where VanStatementAbstract.DocSerial = @DocSerial  
