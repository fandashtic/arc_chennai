
Create Procedure spr_list_Closing_Stock    
(     
@Given_Date DateTime,     
@UOM nVarchar(256)    
)    
AS    
Begin  
  
Declare @Operating_Period as DateTime  
  
Select @Given_Date = dbo.StripDatefromTime(@Given_Date)   
Select @Operating_Period = dbo.StripDatefromTime (getdate())   
  
  
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert InTo #tmpProd Select Product_code From Items  
  
  
--This table is to display the categories in the Order  
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)    
Exec sp_CatLevelwise_ItemSorting   
  
create table #tmptotal_Invd_qty(   
 product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
 , Invoiced_qty decimal(18, 6)  
 )  
  
create table #tmptotal_rcvd_qty(   
 product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
 , rcvdqty decimal(18, 6)  
 , freeqty decimal(18, 6)  
 )  
  
create table #tmptotal_Invd_Saleonly_qty(   
 product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
 , Saleableonly_qty decimal(18, 6)  
 )  
  
Insert Into #tmptotal_Invd_qty  
select tmp.product_code, isnull(sum(IDR.quantity), 0) from #tmpProd tmp   
 left outer join InvoiceDetailReceived IDR on IDR.product_code = tmp.product_code  
 left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId  
 where IAR.Status & 64 = 0 And IAR.InvoiceDate < dateadd(d, 1, @Given_Date)   
  and IAR.Invoicetype = 0   
 group by tmp.product_code   
  
 --total_received_qty(Saleable), total_received_qty(Free)  
Insert Into #tmptotal_rcvd_qty  
select tmp.product_code, isnull(sum(gdt.quantityreceived),0), isnull(sum(gdt.Freeqty),0)  
 from #tmpProd tmp left outer join   
 ( select IsNull(gdt.quantityreceived, 0) as quantityreceived,   
  IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code  
  from grndetail gdt   
  join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus = 1 and gab.RecdInvoiceId in   
  ( select InvoiceId from Invoiceabstractreceived IAR   
   where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @Given_Date)   
   and IAR.Invoicetype = 0   
  )  
 ) gdt on gdt.product_code = tmp.product_code  
group by tmp.product_code  
  
  
-- saleable_sit_qty = total_Invoiced_Saleableonly_qty - total_received_Saleableonly_qty    
-- total_Invoiced_Saleableonly_qty  
Insert Into #tmptotal_Invd_Saleonly_qty  
select tmp.product_code, IsNull(sum(IDR.quantity), 0) from #tmpProd tmp  
 left outer join InvoiceDetailReceived IDR on IDR.product_code = tmp.product_code   
 left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId  
 where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @Given_Date)   
  and IDR.product_code = tmp.Product_code and IAR.Invoicetype = 0   
  and IDR.Saleprice > 0   
 group by tmp.product_code   
  
If @UOM = N'Base UOM'  
 Set @UOM = N'Sales UOM'    
  
If @UOM = N'Sales UOM'    
  Begin  
    If @Operating_Period <= @Given_Date   
 Select Batch_Products.Product_Code, "Item Code" = Batch_Products.Product_Code,  
      "Saleable Stock" = Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0   
        Then Quantity Else 0 End) + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0), -- ' ' + UOM.Description,   
      "Free Stock" = Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0   
        Then Quantity Else 0 End) + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice = 0),0), -- ' ' + UOM.Description   
  
      "Saleable SIT" = IsNull((Select Sum(Case When IsNull(IR.SalePrice,0) > 0    
        Then IR.Pending Else 0 End)   
  From InvoiceDetailReceived IR, InvoiceAbstractReceived AR  
        Where IR.Product_Code = Batch_Products.Product_Code
        And IR.InvoiceID = AR.InvoiceID
        And AR.Status & 64 = 0 
  And (IsNull(IR.SalePrice,0) > 0)),0),  
  
      "Free SIT" = IsNull((Select Sum(Case When IsNull(IR.SalePrice,0) = 0    
        Then IR.Pending Else 0 End)   
  From InvoiceDetailReceived IR, InvoiceAbstractReceived AR 
        Where IR.Product_Code = Batch_Products.Product_Code
		And IR.InvoiceID = AR.InvoiceID
        And AR.Status & 64 = 0  
  And (IsNull(IR.SalePrice,0) = 0)),0),    -- ' ' + UOM.Description,   
  
  "Saleable SIT Value" = IsNull((Cast((Select (Case IC.Price_Option  
  When 0 Then  
  Cast(Sum(Case When IsNull(IR.SalePrice,0) > 0 Then   
  (IR.Pending * IT.Purchase_Price) Else 0 End) As Decimal (18,6))  
  Else  
  Cast(Sum(Case When IsNull(IR.SalePrice, 0) > 0 Then   
  (IR.Pending * (Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End)) Else 0 End) As Decimal(18,6))  
  End )  
  From Items IT, ItemCategories IC, InvoiceDetailReceived IR, InvoiceAbstractReceived AR  
  Where IT.CategoryID = IC.CategoryID  
  And IR.Product_Code = IT.Product_Code  
  And IR.InvoiceID = AR.InvoiceID
  And AR.Status & 64 = 0
  And IT.Product_Code = Batch_Products.Product_Code  
  And IsNull(IR.SalePrice,0)>0 Group by IC.Price_Option)As Decimal(18,6))),0),  
  
  
      "Closing Value" = Cast((Case ItemCategories.Price_Option When 0 Then  
        Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
        Cast((Quantity * Items.Purchase_Price) as Decimal(18,6)) Else 0 End)as Decimal(18,6)) +   
        Cast (IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As Decimal(18, 6))  
        Else Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
        Cast((Quantity * Batch_Products.PurchasePrice) as Decimal(18,6)) Else 0 End)   
        as Decimal(18,6)) End) as Decimal(18,6)) +   
        Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As Decimal(18, 6)),  
      "Forum Code" = Items.Alias   
      From Batch_Products, Items, UOM, ItemCategories, #tempCategory1 T1 Where Items.UOM = UOM.UOM  
      and Items.CategoryID = ItemCategories.CategoryID    
   And Items.CategoryID = T1.CategoryID  
      And Batch_Products.Product_Code = Items.Product_Code Group By T1.IDS, Batch_Products.Product_Code,   
      ItemCategories.Price_Option,Items.Alias --, UOM.Description  
      Order by T1.IDS, Batch_Products.Product_Code  
    Else  
      select OpeningDetails.Product_Code, "Item Code" = OpeningDetails.Product_Code,   
      "Saleable Stock" = Cast(Opening_Quantity - Damage_Opening_Quantity as nVarchar), --+ ' ' + UOM.Description,   
      "Free Stock" = Cast(Free_Opening_Quantity as nVarchar), --+ ' ' + UOM.Description   
  
   "Saleable SIT" = IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),  
  
   "Free SIT" = IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),  
  
   "Saleable SIT Value" = Cast(IsNull(Case Items.Purchased_At when 1 then (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0)   
              When 2 then (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTR, 0) End,0) As Decimal(18,6)),  
  
      "Closing Value" = Opening_Value,  
      "Forum Code" = Items.Alias   
      from OpeningDetails
	Inner Join Items On OpeningDetails.Product_Code = Items.Product_Code 
	Inner Join UOM  On Items.UOM = UOM.UOM  
    Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
	Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code   
	Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code 
	Inner Join  #tempCategory1 T1 On  Items.categoryID = T1.CategoryID    
      Where Opening_Date = DateAdd(day,1,@Given_date)  
      Order by T1.IDS, OpeningDetails.Product_Code  
  End  
  
Else If @UOM = N'Conversion Factor'   
  Begin   
    If @Operating_Period <= @Given_Date   
Select Batch_Products.Product_Code, "Item Code" = Batch_Products.Product_Code,  

"Saleable Stock" = (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END) *  
                        (Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0  Then Quantity Else 0 End) +  IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail  Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0)),  -- + ' ' + Isnull(ConversionTable.ConversionUnit, ''),   
"Free Stock" = (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE   
                IsNull(Items.ConversionFactor,0) END) * (Sum(Case When IsNull(Free, 0) = 1   
                And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) +   
                IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice = 0),0)), --+ ' ' + Isnull(ConversionTable.ConversionUnit, '')   
  
"Saleable SIT" = IsNull((Select(CASE IsNull(IT.ConversionFactor,0) WHEN 0 THEN 1   
                        ELSE IsNull(IT.ConversionFactor,0) END) *  
  Sum(Case When IsNull(IR.SalePrice,0) > 0    
        Then IR.Pending Else 0 End)   
  From InvoiceDetailReceived IR
  Inner Join  Items IT On IT.Product_Code = IR.Product_Code
  Left Outer Join ConversionTable CT On IT.ConversionUnit = CT.ConversionID
  Inner Join InvoiceAbstractReceived AR On IR.InvoiceID = AR.InvoiceID--, Batch_Products BP, GRNAbstract GA,  
  Where  AR.Status & 64 = 0  
  AND IR.Product_Code = Batch_Products.Product_Code  
  And (IsNull(IR.SalePrice,0) > 0)Group By IT.ConversionFactor),0), "Free SIT" = IsNull((Select (CASE IsNull(IT.ConversionFactor,0) WHEN 0 THEN 1 ELSE   
                IsNull(IT.ConversionFactor,0) END) *   
    Sum(Case When IsNull(IR.SalePrice,0) = 0    
    Then IR.Pending Else 0 End)   
    From InvoiceDetailReceived IR
	Inner Join Items IT On IT.Product_Code = IR.Product_Code
	Left Outer Join ConversionTable CT On IT.ConversionUnit = CT.ConversionID
	Inner Join InvoiceAbstractReceived AR On IR.InvoiceID = AR.InvoiceID
    Where AR.Status & 64 = 0
    AND IR.Product_Code = Batch_Products.Product_Code  
    And (IsNull(IR.SalePrice,0) = 0) Group By IT.ConversionFactor),0),  
"Saleable SIT Value" = IsNull(Cast((Select Case IC.Price_Option  
When 0 Then  
Cast(Sum(Case When IsNull(IR.SalePrice,0) > 0 Then   
(IR.Pending * IT.Purchase_Price) Else 0 End) As Decimal (18,6))  
Else  
Cast(Sum(Case When IsNull(IR.SalePrice, 0) > 0 Then   
(IR.Pending * (Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End)) Else 0 End) As Decimal(18,6))  
End  
From Items IT, ItemCategories IC, InvoiceDetailReceived IR, InvoiceAbstractReceived AR
Where IT.CategoryID = IC.CategoryID  
And IR.InvoiceID = AR.InvoiceID
And AR.Status & 64 = 0
And IR.Product_Code = IT.Product_Code  
And IT.Product_Code = Batch_Products.Product_Code  
And IsNull(IR.SalePrice,0)>0 Group By IC.Price_Option) As Decimal(18,6) ),0),  
  
  
"Closing Value" = Cast((Case ItemCategories.Price_Option When 0 Then  
                  Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0   
                  Then (Quantity * Items.Purchase_Price) Else 0 End)) as Decimal(18,6)) +   
                  Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail  
                  Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As Decimal(18, 6))  
Else  
Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then (Quantity * Batch_Products.PurchasePrice) Else 0 End)) as Decimal(18,6))    
End) as Decimal(18,6)) + Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From   
vanstatementdetail Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As Decimal(18, 6)),  
"Forum Code" = Items.Alias   
From Batch_Products
Inner Join Items On Batch_Products.Product_Code = Items.Product_Code
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID   
Group By T1.IDS, Batch_Products.Product_Code, Items.ConversionFactor, ItemCategories.Price_Option,Items.Alias --, ConversionTable.ConversionUnit  
Order by T1.IDS, Batch_Products.Product_Code  
Else  
select OpeningDetails.Product_Code, "Item Code" = OpeningDetails.Product_Code,   
"Saleable Stock" = Cast(Cast((Opening_Quantity - Damage_Opening_Quantity) * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END)as Decimal(18,6)) as nVarchar), --+ ' ' + Isnull(ConversionTable.ConversionUnit, '')
   
"Free Stock" = Cast(Cast(Free_Opening_Quantity * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END)as Decimal(18,6))  as nVarchar), -- + ' ' + Isnull(ConversionTable.ConversionUnit, '')    
  
"Saleable SIT" = IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),  
  
  
"Free SIT" = IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),  
  
  
"Saleable SIT Value" = Cast(IsNull(Case Items.Purchased_At when 1 then (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0)   
            When 2 then (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTR, 0) End,0) As Decimal(18,6)),  
  
"Closing Value" = Opening_Value,  
"Forum Code" = Items.Alias   
from OpeningDetails
Inner Join Items On OpeningDetails.Product_Code = Items.Product_Code
Left Outer Join ConversionTable  On  Items.ConversionUnit = ConversionTable.ConversionID  
Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
Left Outer Join #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code    
Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
Inner Join #tempCategory1 T1  On Items.CategoryID = T1.CategoryID  
Where Opening_Date = DateAdd(day,1,@Given_date)  
Order by T1.IDS, OpeningDetails.Product_Code  
End  
  
Else If @UOM = N'Reporting UOM'    
Begin  
If @Operating_Period <= @Given_Date   
Select Batch_Products.Product_Code,  
"Item Code" = Batch_Products.Product_Code,  
"Saleable Stock" = Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code,   
                   Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
                   Quantity Else 0 End) + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0)) as Decimal(18,6)),   
"Free Stock" = Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code,   
               Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity   
               Else 0 End) + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice = 0),0)) as Decimal(18,6)),   
  
"Saleable SIT" = Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code,   
   IsNull((Select Sum(Case When IsNull(IR.SalePrice,0) > 0    
   Then IR.Pending Else 0 End)   
   From InvoiceDetailReceived IR, InvoiceAbstractReceived AR Where  
   IR.Product_Code = Batch_Products.Product_Code 
   And IR.InvoiceID = AR.InvoiceID
   And AR.Status & 64 = 0
   And IsNull(IR.SalePrice,0) > 0),0)) as Decimal(18,6)),  
  
"Free SIT" = Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code,   
   IsNull((Select Sum(Case When IsNull(IR.SalePrice,0) = 0    
   Then IR.Pending Else 0 End)   
   From InvoiceDetailReceived IR, InvoiceAbstractReceived AR Where  
   IR.Product_Code = Batch_Products.Product_Code  
   And IR.InvoiceID = AR.InvoiceID
   And AR.Status & 64 = 0
   And IsNull(IR.SalePrice,0) = 0),0)) as Decimal(18,6)),  
  
"Saleable SIT Value" = IsNull(Cast((Select Case IC.Price_Option  
When 0 Then  
Cast(Sum(Case When IsNull(IR.SalePrice,0) > 0 Then   
(IR.Pending * IT.Purchase_Price) Else 0 End) As Decimal (18,6))  
Else  
Cast(Sum(Case When IsNull(IR.SalePrice, 0) > 0 Then   
(IR.Pending * (Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End)) Else 0 End) As Decimal(18,6))  
End  
From Items IT, ItemCategories IC, InvoiceDetailReceived IR, InvoiceAbstractReceived AR 
Where IT.CategoryID = IC.CategoryID  
And IR.Product_Code = IT.Product_Code  
And IR.InvoiceID = AR.InvoiceID
And AR.Status & 64 = 0
And IT.Product_Code = Batch_Products.Product_Code  
And IsNull(IR.SalePrice,0)>0 Group By IC.Price_Option)As Decimal(18,6)),0),  
  
"Closing Value" = Cast((Case ItemCategories.Price_Option  
When 0 Then  
Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
(Quantity * Items.Purchase_Price) Else 0 End)) as Decimal(18,6)) +  
Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As   
Decimal(18, 6))  
Else  
Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
(Quantity * Batch_Products.PurchasePrice) Else 0 End)) as Decimal(18,6)) +  
Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail  
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As   
Decimal(18, 6)) End)as Decimal(18,6)),  
"Forum Code" = Items.Alias   
From Batch_Products, Items, ItemCategories, #tempCategory1 T1  
Where Items.CategoryID = ItemCategories.CategoryID  
and Batch_Products.Product_Code = Items.Product_Code  
And Items.CategoryID = T1.CategoryID  
Group By T1.IDS, Batch_Products.Product_Code, ItemCategories.Price_Option,Items.Alias  
Order by T1.IDS, Batch_Products.Product_Code  
Else  
select OpeningDetails.Product_Code, "Item Code" = OpeningDetails.Product_Code,   
"Saleable Stock" = dbo.sp_Get_ReportingUOMQty(OpeningDetails.Product_Code,Opening_Quantity - Damage_Opening_Quantity),  
  
"Free Stock" = dbo.sp_Get_ReportingUOMQty(OpeningDetails.Product_Code,Free_Opening_Quantity),  
  
"Saleable SIT" = IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),  
  
"Free SIT" = IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),  
  
"Saleable SIT Value" = Cast(IsNull(Case Items.Purchased_At when 1 then (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTS, 0)   
            When 2 then (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty) * Isnull(Items.PTR, 0) End,0) As Decimal(18,6)),  
  
"Closing Value" = Opening_Value,  
"Forum Code" = Items.Alias   
from OpeningDetails
Inner Join Items On OpeningDetails.Product_Code = Items.Product_Code
Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
Left Outer Join #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code    
Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID   
Where Opening_Date = DateAdd(day,1,@Given_date)  
Order by T1.IDS, OpeningDetails.Product_Code  
End  
  
Drop table #tmpProd  
Drop table #tmptotal_Invd_qty  
Drop table #tmptotal_rcvd_qty  
Drop table  #tmptotal_Invd_Saleonly_qty  
End  

