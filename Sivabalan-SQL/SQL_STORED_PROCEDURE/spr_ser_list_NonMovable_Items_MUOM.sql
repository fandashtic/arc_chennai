CREATE procedure spr_ser_list_NonMovable_Items_MUOM(@ShowItems nvarchar(255), @FromDate datetime, @ToDate datetime , @UOM nvarchar(50))  
as  
declare @SerInvDate datetime
declare @InvDate datetime

If IsNull(@UOM,'') = '' or @UOM = '%' 
Set @UOM = 'Sales UOM'      
if @ShowItems = 'Items With Stock'
begin

   select Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,   
	"Description" = Items.Description, "Category" = ItemCategories.Category_Name,   
	"Last Sale Date" = (
		Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.InvoiceDate < @FromDate and  
			InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceDate < @FromDate and  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                         IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and
			ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt ),   
	"Saleable Stock" = Case @UOM When 'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Damaged Stock" = Case @UOM When 'Sales UOM' Then  ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End, 
	"Free Stock" = Case @UOM When 'Sales UOM' Then  ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Maximum Stock" = Case @UOM When 'Sales UOM' Then  ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails 
				where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails 
				where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Total Stock" = Case @UOM When 'Sales UOM' Then  ISNULL((select Sum(Quantity) from Batch_products   
			where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Quantity) from Batch_products   
			where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products  
			where Batch_Products.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
	From Items, ItemCategories, Batch_Products  
	where 
	(Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )  
		from InvoiceDetail, InvoiceAbstract  
		where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
                InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
		InvoiceAbstract.Status & 128 = 0 and  
		InvoiceAbstract.InvoiceType in (1,2,3)) 
		and 
	Items.Product_Code not in (select distinct(ServiceInvoiceDetail.Sparecode )  
		from ServiceInvoiceDetail, ServiceInvoiceAbstract  
		where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID and  
                ServiceInvoiceAbstract.ServiceInvoiceDate between @FromDate and @ToDate and   
		Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
                IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  and
		ServiceInvoiceAbstract.ServiceInvoiceType in (1))) 

	And
	Items.CategoryID = ItemCategories.CategoryID And 
	Batch_Products.Product_Code = Items.Product_Code 
	group by Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.UOM1_Conversion,Items.UOM2_Conversion
	having sum(Batch_Products.Quantity) > 0  
  end
else 
  begin
    select  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,   
	 "Description" = Items.Description, "Category" = ItemCategories.Category_Name,   
	 "Last Sale Date" = (
		Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.InvoiceDate < @FromDate and  
			InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceDate < @FromDate and  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   
"Saleable Stock" = Case @UOM When 'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Damaged Stock" = Case @UOM When 'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Free Stock" = Case @UOM When 'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Maximum Stock" = Case @UOM When 'Sales UOM' Then  ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails 
				where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails 
				where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Total Stock" = Case @UOM When 'Sales UOM' Then  ISNULL((select Sum(Quantity) from Batch_products   
			where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Quantity) from Batch_products   
			where Batch_Products.Product_Code = Items.Product_Code), 0)
				, (Case @UOM --When 'Sales UOM' Then 1
				When 'Uom1' Then IsNull(Items.UOM1_Conversion,1)
				When 'Uom2' Then IsNull(Items.UOM2_Conversion,1)
				End)) End,
	"Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products  
			where Batch_Products.Product_Code = Items.Product_Code), 0)as Decimal(18,6))
	From Items,ItemCategories  
	where 
	(Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )  
		from InvoiceDetail, InvoiceAbstract  
		where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
                InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
		InvoiceAbstract.Status & 128 = 0 and  
		InvoiceAbstract.InvoiceType in (1,2,3)) 
		And
	Items.Product_Code not in (select distinct(ServiceInvoiceDetail.Sparecode )  
		from ServiceInvoiceDetail, ServiceInvoiceAbstract  
		where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID and  
                ServiceInvoiceAbstract.ServiceInvoiceDate between @FromDate and @ToDate and   
		Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
                IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  and
		ServiceInvoiceAbstract.ServiceInvoiceType in (1))) 
	And
	Items.CategoryID = ItemCategories.CategoryID    
 end






