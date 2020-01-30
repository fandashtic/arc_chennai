Create Procedure spr_ClosingPipeLine(@InvId nvarchar(100),@Manufacturer nVarchar(100),@ToDate DateTime)        
As        
Begin     
Set DateFormat DMY       
Declare @WDCode NVarchar(255),@WDDest NVarchar(255),@NEXT_DATE DateTime,@CORRECTED_DATE DateTime          
Declare @CompaniesToUploadCode NVarchar(255)          
Declare @Delimeter Char(1)    
Set @Delimeter = Char(15)    
        
Create Table #TempCategory (CategoryID Int, Status Int)    
Create Table #TempManufacturer(Mname nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
If @Manufacturer = N'%'    
Insert into #TempManufacturer Select Manufacturer_Name From Manufacturer    
else    
Insert into #TempManufacturer Select * From Dbo.sp_SplitIn2Rows(@Manufacturer, @Delimeter)    
    
          
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload          
Select Top 1 @WDCode = RegisteredOwner From Setup            
          
If @CompaniesToUploadCode='ITC001'          
Begin          
 Set @WDDest= @WDCode          
End          
Else          
Begin          
 Set @WDDest= @WDCode          
 Set @WDCode= @CompaniesToUploadCode          
End          
          
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS varchar) + '/'                       
+ CAST(DATEPART(mm, @TODATE) as varchar) + '/'                       
+ cast(DATEPART(yyyy, @TODATE) AS varchar)                      
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/'                       
+ CAST(DATEPART(mm, GETDATE()) as varchar) + '/'                       
+ cast(DATEPART(yyyy, GETDATE()) AS varchar)                      
          
Exec GetLeafCategories N'%', '%'        
            
Create Table #TempConsolidate (CategoryID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,WDCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,WDDest NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,           
 SystemSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Cl. SOH] Decimal(18, 6),[Sales Quantity] Decimal (18,6) default (0),[Sales Value] Decimal(18,6) default (0))          
        
Insert InTo #TempConsolidate(CategoryID,WDCode,WDDest, SystemSKU, [Cl. SOH])            
Select          
"Category ID"= itc.CategoryID,          
"WD Code"=@WDCode,"WD Dest"=@WDDest,          
"System SKU" = I.Product_Code,                  
"Cl. SOH" =             
 CASE When (@TODATE < @NEXT_DATE) THEN             
  ISNULL((Select Sum(IsNull(Opening_Quantity, 0)) FROM OpeningDetails, Items             
  WHERE OpeningDetails.Product_Code = Items.Product_Code And      
  I.Product_Code = Items.Product_Code And           
  Items.CategoryID = itc.CategoryID AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) -          
          
  ISNULL((Select Sum(IsNull(Damage_Opening_Quantity, 0)) FROM OpeningDetails, Items             
  WHERE OpeningDetails.Product_Code = Items.Product_Code And             
  I.Product_Code = Items.Product_Code And           
  Items.CategoryID = itc.CategoryID AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)            
             
 Else            
  ISNULL((SELECT SUM(Quantity) FROM Batch_Products, Items             
  WHERE Batch_Products.Product_Code = Items.Product_Code And             
  I.Product_Code = Items.Product_Code And           
  Items.CategoryID = itc.CategoryID And IsNull(Damage,0)=0), 0) +                      
          
  (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract, Items             
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
  AND (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code And             
  I.Product_Code = Items.Product_Code And           
  Items.CategoryID = itc.CategoryID And VanStatementDetail.PurchasePrice <> 0)   +          
          
  (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract, Items             
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                       
  AND (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code And             
  I.Product_Code = Items.Product_Code And           
  Items.CategoryID = itc.CategoryID And VanStatementDetail.PurchasePrice = 0)       
    
 End          
          
From ItemCategories itc, Items I, Manufacturer M  Where               
Itc.CategoryId = I.CategoryId And          
I.ManufacturerID = M.ManufacturerID And I.Active = 1 And     
itc.CategoryID In (Select CategoryID From #TempCategory)            
And M.Manufacturer_name In (Select MName from #TempManufacturer)        
      

update #TempConsolidate set [Sales Quantity] = isnull(Q.Quantity,0)
from  
(  
Select sum(case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) as "Quantity",IDt.Product_Code as "ProductCode"  
From #TempConsolidate T,InvoiceAbstract IA,InvoiceDetail IDt  
 Where  
 IA.InvoiceID = IDt.InvoiceID     
 And T.SystemSKU = IDt.Product_Code  
 and dbo.stripdatefromtime(IA.InvoiceDate)=@CORRECTED_DATE  
 and (IA.Status & 192) = 0    
 group by IDt.Product_Code
) Q  
where Q.ProductCode=#TempConsolidate.SystemSKU
  
update #TempConsolidate set [Sales Value] = isnull(Val.[Value],0)  
from  
(  
Select Sum(case IA.InvoiceType when 4 then -IDt.Amount else IDt.Amount end) as "Value",IDt.Product_Code as "ProductCode"     
From #TempConsolidate T,InvoiceAbstract IA,InvoiceDetail IDt  
 Where  
 IA.InvoiceID = IDt.InvoiceID     
 And T.SystemSKU = IDt.Product_Code  
 and dbo.stripdatefromtime(IA.InvoiceDate)=@CORRECTED_DATE  
 and (IA.Status & 192) = 0    
 group by IDt.Product_Code
) Val  
where Val.ProductCode=#TempConsolidate.SystemSKU  

/* Order Qty and Value should be shown to the user when flag is enabled*/
Alter Table #TempConsolidate Add [Order Qty] Decimal(18,6) not null default 0,[Order Value] Decimal(18,6) not null default 0
,[Pending Order Quantity] Decimal (18,6) NOT NULL Default 0 ,[Pending Order Value] Decimal (18,6) NOT NULL Default 0 
if (Select isnull(flag,0) from Tbl_merp_Configabstract where screencode='LEAN_INVT')=1
Begin
	Create Table #tmpSO(Item_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,OrdQty Decimal(18,6),OrdValue Decimal(18,6),PendingOrdQty Decimal (18,6),PendingOrdValue Decimal (18,6))

	insert into #tmpSO(Item_Code,OrdQty,OrdValue,PendingOrdQty,PendingOrdValue) 
	Select SOD.Product_code,sum(isNull(SOD.Quantity,0)),Case Isnull(SoD.TAXONQTY,0) When 0 Then (Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) * Saletax/100))) Else
	(Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * Saletax))) End 
						   ,Sum(Isnull(SOD.Pending,0)), Case Isnull(SoD.TAXONQTY,0) When 0 Then (Sum(isNull(SOD.Pending,0)  * isNull(SOD.Saleprice,0)  + (isNull(SOD.Pending,0)  * isNull(SOD.Saleprice,0) * Saletax/100))) Else
	(Sum(isNull(SOD.Pending,0)  * isNull(SOD.Saleprice,0)  + (isNull(SOD.Pending,0)  * Saletax))) End 
	From SOAbstract SOA,SODetail SOD 
	where dbo.stripdatefromtime(SODate)=@CORRECTED_DATE
	And SOA.SONumber=SOD.SONumber
	And IsnULL(SOA.Status,0) in (2,130,134,6,194)
	And Isnull(Status,0) & 192<>192
	Group by SOD.Product_code,Isnull(SoD.TAXONQTY,0) 

	Update T set T.[Order Qty]=isnull(S.OrdQty,0),T.[Order Value]=isnull(S.OrdValue,0) , T.[Pending Order Quantity] = ISNULL(S.PendingOrdQty,0) ,T.[Pending Order Value] = ISNULL(s.PendingOrdValue,0)  From #TempConsolidate T,#tmpSO S
	Where S.Item_Code=T.SystemSKU
	
	Drop Table #tmpSO
End
  
-- Consolidation         
     
Declare @SYSSKU NVarchar(50)          
Declare @SUBTOTAL NVarchar(50)          
Declare @GRNTOTAL NVarchar(50)          
          
Set @SYSSKU = dbo.LookupDictionaryItem(N'SystemSKU', Default)           
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)           
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)           
        
If (Select Count(*) From Reports Where ReportName = 'Closing PipeLine' And ParameterID in           
 (Select ParameterID From dbo.GetReportParametersForCPL('Closing PipeLine') Where           
 ToDate = dbo.StripDateFromTime(@ToDate))) >=1          
Begin          
 Insert Into #TempConsolidate (CategoryID, WDCode, WDDest, SystemSKU, [Cl. SOH])          
 Select IsNull(dbo.GetCategorieId(ReportAbstractReceived.Field3),0),    
 "WD Code" = ReportDetailReceived.Field1,    
 "WD Dest" = ReportDetailReceived.Field2,      
 "SystemSKU" = ReportDetailReceived.Field3,              
 "[Cl. SOH]" = Cast(Cast(ReportDetailReceived.Field4 as float)as Decimal(18,6))          
 From ReportAbstractReceived,ReportDetailReceived,Items     
 Where ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID And        
 Items.Product_Code = ReportDetailReceived.Field3 And    
 Items.ManufacturerID In (Select ManufacturerID From Manufacturer Where Manufacturer_Name In (Select * from #TempManufacturer)) And    
 ReportAbstractReceived.ReportID in                   
  (Select Distinct ReportID From Reports                         
  Where ReportName = 'Closing PipeLine'        
  And ParameterID in (Select ParameterID From dbo.GetReportParametersForCPL('Closing PipeLine') Where                  
  ToDate =  dbo.StripDateFromTime(@ToDate)))          
 And ReportDetailReceived.Field3 <> @SYSSKU          
 And ReportDetailReceived.Field1 <> @SUBTOTAL              
 And ReportDetailReceived.Field1 <> @GRNTOTAL           
End        
    
Select * From #TempConsolidate        
        
Drop Table #TempCategory        
Drop Table #TempConsolidate            
Drop Table #TempManufacturer    
End         
