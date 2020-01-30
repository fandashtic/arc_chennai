CREATE procedure spr_list_NonMovable_Items(@ShowItems nvarchar(255), @FromDate datetime, @ToDate datetime)  
as  
if @ShowItems = 'Items With Stock'
  begin
   select  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,   
	 "Description" = Items.Description, "Category" = ItemCategories.Category_Name,   
	 "Last Sale Date" = (select Max(InvoiceAbstract.InvoiceDate)  
	 from InvoiceAbstract, InvoiceDetail  
	 where InvoiceAbstract.InvoiceDate < @FromDate and  
	 InvoiceAbstract.Status & 128 = 0 and  
	 InvoiceAbstract.InvoiceType in (1,2,3) and  
	 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
	 InvoiceDetail.Product_Code = Items.Product_Code),   
	"Saleable Stock" = ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0),
	"Damaged Stock" = ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0), 
	"Free Stock" = ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0), 
	"Maximum Stock" = ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails 
				where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0), 
	"Total Stock" = ISNULL((select Sum(Quantity) from Batch_products   
			where Batch_Products.Product_Code = Items.Product_Code), 0),  
	"Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products  
			where Batch_Products.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
	From Items, ItemCategories, Batch_Products  
	where   
	Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )  
		from InvoiceDetail, InvoiceAbstract  
		where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
		InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
		InvoiceAbstract.Status & 128 = 0 and  
		InvoiceAbstract.InvoiceType in (1,2,3)) And  
	Items.CategoryID = ItemCategories.CategoryID And 
	Batch_Products.Product_Code = Items.Product_Code 
   group by Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name
   having sum(Batch_Products.Quantity) > 0
  end
else 
  begin
    select  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,   
	 "Description" = Items.Description, "Category" = ItemCategories.Category_Name,   
	 "Last Sale Date" = (select Max(InvoiceAbstract.InvoiceDate)  
	 from InvoiceAbstract, InvoiceDetail  
	 where InvoiceAbstract.InvoiceDate < @FromDate and  
	 InvoiceAbstract.Status & 128 = 0 and  
	 InvoiceAbstract.InvoiceType in (1,2,3) and  
	 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
	 InvoiceDetail.Product_Code = Items.Product_Code),   
	"Saleable Stock" = ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0),
	"Damaged Stock" = ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0), 
	"Free Stock" = ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products   
				where Batch_Products.Product_Code = Items.Product_Code), 0), 
	"Maximum Stock" = ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails 
				where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0), 
	"Total Stock" = ISNULL((select Sum(Quantity) from Batch_products   
			where Batch_Products.Product_Code = Items.Product_Code), 0),  
	"Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products  
			where Batch_Products.Product_Code = Items.Product_Code), 0) as Decimal(18,6))
	From Items, ItemCategories  
	where   
	Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )  
	from InvoiceDetail, InvoiceAbstract  
	where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
	InvoiceAbstract.Status & 128 = 0 and  
	InvoiceAbstract.InvoiceType in (1,2,3)) and  
	Items.CategoryID = ItemCategories.CategoryID  
	  
    end

