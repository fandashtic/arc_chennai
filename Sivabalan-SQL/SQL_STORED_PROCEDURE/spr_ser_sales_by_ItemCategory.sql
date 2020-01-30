CREATE procedure [dbo].[spr_ser_sales_by_ItemCategory](@CATNAME NVARCHAR (4000),      
                 @FROMDATE DATETIME,      
                 @TODATE DATETIME)      
As      
      
DECLARE @UOMCOUNT int      
DECLARE @REPORTINGCOUNT int      
DECLARE @CONVERSIONCOUNT int      

DECLARE @SERVICEUOMCOUNT int      
DECLARE @SERVICEREPORTINGCOUNT int      
DECLARE @SERVICECONVERSIONCOUNT int      


DECLARE @TOTALUOMCOUNT int      
DECLARE @TOTALREPORTINGCOUNT int      
DECLARE @TOTALCONVERSIONCOUNT int      

declare @UOMDESC nvarchar(50)      
declare @ReportingUOM nvarchar(50)      
declare @ConversionUnit nvarchar(50)
      
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
      
Create Table #temp(CategoryID int,      
     Category_Name nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,      
     Status int)      
      
Create Table #TmpCat (Category varchar(255)collate SQL_Latin1_General_Cp1_CI_AS)      


      
If @CATNAME = '%'       
 Insert Into #TmpCat Select Category_Name From ItemCategories      
Else      
 Insert Into #TmpCat Select * From dbo.sp_SplitIn2Rows(@CATNAME,@Delimeter)      
      
Declare @Continue int      
Declare @CategoryID int      
Set @Continue = 1      
Insert into #temp select CategoryID, Category_Name, 0 From ItemCategories      
Where Category_Name in (Select Category From #TmpCat)      
While @Continue > 0      
Begin      
 Declare Parent Cursor Static For      
 Select CategoryID From #temp Where Status = 0      
 Open Parent      
 Fetch From Parent Into @CategoryID      
 While @@Fetch_Status = 0      
 Begin      
  Insert into #temp       
  Select CategoryID, Category_Name, 0 From ItemCategories       
  Where ParentID = @CategoryID      
  Update #temp Set Status = 1 Where CategoryID = @CategoryID      
  Fetch Next From Parent Into @CategoryID      
 End      
 Close Parent      
 DeAllocate Parent      
 Select @Continue = Count(*) From #temp Where Status = 0      
End      

select @UOMCOUNT = count(distinct uom) from (
Select  Distinct Items.UOM UOM     
From Items,InvoiceDetail, ItemCategories, InvoiceAbstract      
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND      
InvoiceDetail.Product_Code = Items.Product_Code AND      
Items.CategoryID = ItemCategories.CategoryID AND      
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND      
InvoiceAbstract.Status & 128 = 0 AND      
InvoiceAbstract.InvoiceType in (1, 2, 3)      
union

Select  Distinct Items.UOM      
From Items,serviceInvoiceDetail, ItemCategories, serviceInvoiceAbstract      
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID AND      
serviceInvoiceDetail.spareCode = Items.Product_Code AND      
Items.CategoryID = ItemCategories.CategoryID AND      
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
serviceInvoiceAbstract.serviceInvoiceDate between @FROMDATE And @TODATE AND      
isnull(serviceInvoiceAbstract.Status,0) & 192 = 0 AND      
serviceInvoiceAbstract.serviceInvoiceType in (1))as u 


select @REPORTINGCOUNT = count(distinct ReportingUnit) from (
Select Distinct Items.ReportingUnit       
From Items, ItemCategories, InvoiceAbstract, InvoiceDetail      
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND      
InvoiceDetail.Product_Code = Items.Product_Code AND      
Items.CategoryID = ItemCategories.CategoryID AND      
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
InvoiceAbstract.InvoiceDate  Between @FROMDATE And @TODATE AND      
InvoiceAbstract.Status & 128 = 0 AND      
InvoiceAbstract.InvoiceType in (1, 2, 3)  

UNION

Select Distinct Items.ReportingUnit       
From Items,serviceInvoiceDetail, ItemCategories, serviceInvoiceAbstract      
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID AND      
serviceInvoiceDetail.spareCode = Items.Product_Code AND      
Items.CategoryID = ItemCategories.CategoryID AND      
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
serviceInvoiceAbstract.serviceInvoiceDate Between @FROMDATE And @TODATE AND      
isnull(serviceInvoiceAbstract.Status,0) & 192 = 0 AND      
serviceInvoiceAbstract.serviceInvoiceType in (1))AS R      

      

select @CONVERSIONCOUNT = count(distinct ConversionUnit) from (
Select Distinct Items.ConversionUnit      
From Items, ItemCategories, InvoiceAbstract, InvoiceDetail      
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND      
InvoiceDetail.Product_Code = Items.Product_Code AND      
Items.CategoryID = ItemCategories.CategoryID AND      
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND      
InvoiceAbstract.Status & 128 = 0 AND      
InvoiceAbstract.InvoiceType in (1, 2, 3)

UNION

Select  Distinct Items.ConversionUnit      
From Items,serviceInvoiceDetail, ItemCategories, serviceInvoiceAbstract      
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID AND      
serviceInvoiceDetail.spareCode = Items.Product_Code AND      
Items.CategoryID = ItemCategories.CategoryID AND      
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
serviceInvoiceAbstract.serviceInvoiceDate Between @FROMDATE And @TODATE AND            
isnull(serviceInvoiceAbstract.Status,0) & 192 = 0 AND      
serviceInvoiceAbstract.serviceInvoiceType in (1)) AS C      



Create Table #CatTemp(CategoryID int,Code nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS,
CategoryName nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,NetQuantity decimal(18,6),
ConversionQuantity decimal(18,6),ReportingQuantity decimal(18,6), [NetValue] decimal(18,6))


If @UOMCOUNT <= 1 And @REPORTINGCOUNT <= 1 And @CONVERSIONCOUNT <= 1      

Begin

create table #GTemp (Descrip nvarchar(255)collate SQL_Latin1_General_Cp1_CI_AS,invdate datetime) 

 Insert into #GTemp
 Select  UOM.[Description],invoicedate From Items, InvoiceDetail, ItemCategories, InvoiceAbstract, UOM      
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND      
 InvoiceDetail.Product_Code = Items.Product_Code AND      
 Items.CategoryID = ItemCategories.CategoryID AND      
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
 InvoiceAbstract.InvoiceDate Between @FromDate and @Todate And
 InvoiceAbstract.Status & 128 = 0 AND      
 InvoiceAbstract.InvoiceType in (1, 2, 3) AND      
 Items.UOM *= UOM.UOM      


insert into #GTemp

 Select  UOM.[Description],Serviceinvoicedate 
 From Items, ServiceInvoiceDetail, ItemCategories, ServiceInvoiceAbstract, UOM      
 WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND      
 ServiceInvoiceDetail.spareCode = Items.Product_Code AND      
 Items.CategoryID = ItemCategories.CategoryID AND      
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
 ServiceInvoiceAbstract.ServiceInvoiceDate Between  @FromDate and @Todate And         
 Isnull( ServiceInvoiceAbstract.Status,0) & 192 = 0 AND      
 ServiceInvoiceAbstract.ServiceInvoiceType in (1) AND      
 Items.UOM *= UOM.UOM      


select top 1 @UOMDESC = Descrip from #GTemp order by invdate

drop table #GTemp


create table #GTemp1 (Descrip nvarchar(255)collate SQL_Latin1_General_Cp1_CI_AS,invdate datetime) 

insert into #GTemp1

Select ConversionTable.ConversionUnit,invoicedate      
 From Items, InvoiceDetail, ItemCategories, InvoiceAbstract, ConversionTable      
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND      
 InvoiceDetail.Product_Code = Items.Product_Code AND      
 Items.CategoryID = ItemCategories.CategoryID AND      
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
 InvoiceAbstract.InvoiceDate Between   @FromDate and @Todate And         
 InvoiceAbstract.Status & 128 = 0 AND      
 InvoiceAbstract.InvoiceType in (1, 2, 3) AND      
 Items.ConversionUnit *= ConversionTable.ConversionID   

insert into #GTemp1

 Select ConversionTable.ConversionUnit,serviceinvoicedate
 From Items, ServiceInvoiceDetail, ItemCategories, ServiceInvoiceAbstract,conversiontable            
 WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND      
 ServiceInvoiceDetail.spareCode = Items.Product_Code AND      
 Items.CategoryID = ItemCategories.CategoryID AND      
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
 ServiceInvoiceAbstract.ServiceInvoiceDate   Between @FromDate and @Todate And         
Isnull( ServiceInvoiceAbstract.Status,0) & 192 = 0 AND      
 ServiceInvoiceAbstract.ServiceInvoiceType in (1) AND  
 Items.ConversionUnit *= ConversionTable.ConversionID      

select top 1 @ConversionUnit = Descrip from #GTemp1 order by invdate
drop table #GTemp1


create table #GTemp2 (Descrip nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,invdate datetime) 

insert into #GTemp2



	Select  UOM.[Description],invoicedate 
	From Items, InvoiceDetail, ItemCategories, InvoiceAbstract, UOM
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
	InvoiceDetail.Product_Code = Items.Product_Code AND
	Items.CategoryID = ItemCategories.CategoryID AND
	ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND
	InvoiceAbstract.InvoiceDate Between   @FromDate and @Todate And
	InvoiceAbstract.Status & 128 = 0 AND
	InvoiceAbstract.InvoiceType in (1, 2, 3) AND
	Items.ReportingUOM *= UOM.UOM

insert into #GTemp2


	Select  UOM.Description,serviceinvoicedate 
	From Items, ServiceInvoiceDetail, ItemCategories, ServiceInvoiceAbstract, UOM      
	WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND      
	ServiceInvoiceDetail.spareCode = Items.Product_Code AND      
	Items.CategoryID = ItemCategories.CategoryID AND      
	ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND      
	ServiceInvoiceAbstract.ServiceInvoiceDate  Between @FromDate and @Todate And               
	Isnull( ServiceInvoiceAbstract.Status,0) & 192 = 0 AND      
	ServiceInvoiceAbstract.ServiceInvoiceType in (1) AND  
	Items.ReportingUOM *= UOM.UOM

select top 1 @ReportingUom = Descrip from #GTemp2 order by invdate

drop table #GTemp2


	Insert into #CatTemp
	      
	 Select Items.CategoryID, invoicedetail.product_code,"Category Name" = ItemCategories.Category_Name,       
	 "Net Quantity" = SUM(isnull(Quantity,0)),      
	 "Conversion Factor" = SUM(ISNULL(Quantity, 0)),
	
	 "Reporting UOM" = Sum(ISNULL(QUANTITY, 0)),
	      
	 "Net Value (%c)" = sum(Amount)       
	
	 from invoicedetail,InvoiceAbstract,ItemCategories, Items      
	 where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID       
	 and invoicedate Between @FROMDATE And @TODATE AND      
	 InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)      
	 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)      
	 and items.CategoryID=Itemcategories.CategoryID       
	 and items.product_Code=invoiceDetail.product_Code      
	 Group by Items.CategoryID,invoicedetail.product_code,ItemCategories.Category_Name, Items.ReportingUnit
	
	
	Insert into #CatTemp
	
	Select Items.CategoryID,serviceinvoicedetail.sparecode,"Category Name" = ItemCategories.Category_Name,       
	"Net Quantity" = ISNULL(SUM(Quantity), 0), 
	"Conversion Factor" = SUM(ISNULL(Quantity, 0)), 
	"Reporting UOM" = Sum(ISNULL(QUANTITY, 0)),
	  
	 "Net Value (%c)" = sum(isnull(ServiceInvoiceDetail.NetValue,0))       
	 from serviceinvoicedetail,serviceInvoiceAbstract,ItemCategories, Items      
	 where serviceinvoiceAbstract.serviceInvoiceID=serviceInvoiceDetail.serviceInvoiceID       
	 and serviceinvoicedate Between @FROMDATE And @TODATE AND      
	 isnull(serviceInvoiceAbstract.Status,0) & 192=0  and 
	 serviceInvoiceAbstract.serviceInvoiceType in (1)      
	 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)      
	 and items.CategoryID=Itemcategories.CategoryID       
	 and items.product_Code=serviceinvoiceDetail.sparecode 
	 and isnull(serviceinvoicedetail.sparecode ,'')<> ''     
	 Group by Items.CategoryID,serviceinvoicedetail.sparecode,ItemCategories.Category_Name, Items.ReportingUnit
	
	
	
	select #CatTemp.CategoryID,CategoryName,
	"Net Quantity" = sum(NetQuantity),
	
	 "Conversion Factor" = CAST(CAST(SUM(ISNULL(ConversionQuantity, 0) * Items.ConversionFactor) AS Decimal(18,6)) AS VARCHAR)      
	 + ' ' + @ConversionUnit,   
	
	 "Reporting UOM" = Cast(dbo.Sp_Get_ReportingQty(Sum(ISNULL(ReportingQUANTITY, 0)), (CASE Cast(IsNull(Items.ReportingUnit,0) as Int) WHEN 0 THEN 1 ELSE Cast(IsNull(Items.ReportingUnit,1) as Int) END)) As VarChar)
	  + ' ' + @ReportingUOM,      
	
	"Net Value (%c)" = sum(Netvalue)
	
	from #CatTemp,items,ItemCategories
	where ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)      
	and items.CategoryID=Itemcategories.CategoryID       
	and items.product_Code in(select code collate SQL_Latin1_General_Cp1_CI_AS From #CatTemp)
	Group by #CatTemp.CategoryID,CategoryName, ReportingUnit
	drop table #CatTemp

End      

Else      

Begin      

	Insert into #CatTemp
	
	 Select Items.CategoryID,invoicedetail.product_code,"Category Name" = ItemCategories.Category_Name,       
	 "Net Quantity" = ISNULL(SUM(Quantity), 0),      
	 "Conversion Factor" = Null,      
	 "Reporting UOM" = Null,      
	 "Net Value (%c)" = sum(Amount)       
	 from invoicedetail,InvoiceAbstract,ItemCategories, Items      
	 where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID       
	 and invoicedate between @FROMDATE and @TODATE      
	 And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)      
	 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)      
	 and items.CategoryID=Itemcategories.CategoryID       
	 and items.product_Code=invoiceDetail.product_Code      
	 Group by Items.CategoryID,invoicedetail.product_code,ItemCategories.Category_Name      
	
	
	Insert into #CatTemp
	
	 Select Items.CategoryID,Serviceinvoicedetail.sparecode,"Category Name" = ItemCategories.Category_Name,       
	 "Net Quantity" = ISNULL(SUM(Quantity), 0),      
	 "Conversion Factor" = Null,      
	 "Reporting UOM" = Null,      
	 "Net Value (%c)" = sum(isnull(Serviceinvoicedetail.Netvalue,0))       
	 from serviceinvoicedetail,serviceInvoiceAbstract,ItemCategories, Items      
	 where serviceinvoiceAbstract.serviceInvoiceID=serviceInvoiceDetail.serviceInvoiceID       
	And serviceinvoicedate between @FROMDATE and @TODATE      
	And isnull(serviceInvoiceAbstract.Status,0)& 192 =0 
	And serviceInvoiceAbstract.serviceInvoiceType in (1)      
	And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)      
	And items.CategoryID=Itemcategories.CategoryID       
	And items.product_Code=serviceinvoiceDetail.spareCode      
	And isnull(serviceinvoicedetail.sparecode,'') <> ''
	Group by Items.CategoryID,serviceinvoicedetail.sparecode,ItemCategories.Category_Name      
	
	Select #CatTemp.CategoryID,"Category Name" = Categoryname,"Net Quantity" = sum(NetQuantity),
	"Conversion Factor" = Null,      
	"Reporting UOM" = Null,      
	"Net Value (%c)" = sum(Netvalue)       
	from #CatTemp,ItemCategories, Items      
	where ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)      
	And items.CategoryID=Itemcategories.CategoryID       
	And items.product_Code in(select Code collate SQL_Latin1_General_Cp1_CI_AS From #Cattemp)
	Group by #CatTemp.CategoryID,CategoryName
	
	Drop Table #CatTemp

End      

Drop Table #temp      
Drop Table #TmpCat    
--Drop Table #CatTemp
