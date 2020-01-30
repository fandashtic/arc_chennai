Create Function [dbo].[GetTaxDetails] (@InvNo int)        
Returns nvarchar(2000)        
As    

Begin  
  
Declare @Result nvarchar(2000)  
Declare @InvNos nvarchar(200)
Declare @AdjDocs nVarchar(25)
Declare @Tax nvarchar(10)  
Declare @Sale_Value Decimal(18,2)  
Declare @Tax_Amt Decimal(18,2)  
Declare @Total_Tax_Amt Decimal(18,2) 
Declare @Total_Sale_Value Decimal(18,2)  
Declare @Customer_Type int

Set @InvNos= Cast(@InvNo as nvarchar(10)) + ','

Declare AdjustedDocs Cursor Keyset For

Select DocumentID from CollectionDetail where CollectionID =
(Select PaymentDetails from InvoiceAbstract where InvoiceID=@InvNo and DocumentType in (1,4))

Open AdjustedDocs        
Fetch From AdjustedDocs into @AdjDocs
While @@Fetch_Status = 0        
Begin

Set @InvNos = IsNull(@InvNos, N'') + cast(@AdjDocs as nvarchar(10)) + ','

Fetch Next From AdjustedDocs into @AdjDocs
End

Set @InvNos = Left(IsNull(@InvNos, N''),Len(@InvNos)-1)

Set @Result = '  |' + Space(10) +'Tax Details   ' + Space(11) + '|;'    
Set @Result= @Result + '|' + REPLICATE('-',35) + '|;'   
  
Set @Total_Tax_Amt= 0.00 
set @Total_Sale_Value=0.00
Set @Customer_Type=2 
  
Set @Result =  IsNull(@Result, N'') + '| TAX% |  Taxable Sales  | Tax Amt  |' + ';'  

Declare TaxData Cursor Keyset For        

Select Taxcode,Sum(SalesValue) SalesValue,Sum(TaxAmount) From
(SELECT Cast(IsNull(MAX(InvDt.TaxCode), 0) as Decimal(18,2)) [TaxCode], 
Case InvAb.InvoiceType 
When 4 Then
	Cast(-1*(SUM(InvDt.Quantity) * Max(InvDt.SalePrice)) - SUM(INVDt.DiscountValue) as Decimal(18,2)) 
Else 
	Cast((SUM(InvDt.Quantity) * Max(InvDt.SalePrice)) - SUM(INVDt.DiscountValue) as Decimal(18,2)) 
End [SalesValue], 
Case InvAb.InvoiceType 
When 4 Then
	Cast(-1 * (max(TaxAmount) - max(STCredit)) as Decimal(18,2)) 
Else
	Cast((max(TaxAmount)- max(STCredit)) as Decimal(18,2)) 
End [TaxAmount]
FROM InvoiceDetail InvDt

--, Items, ItemCategories, UOM, Batch_Products BP,InvoiceAbstract InvAb
Join InvoiceAbstract InvAb on InvAb.InvoiceID=InvDt.InvoiceID
Join Items on InvDt.Product_Code = Items.Product_Code
Left Join UOM on InvDt.UOM = UOM.UOM 
Left Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Right Join Batch_Products BP on InvDt.Batch_Code = BP.Batch_Code
WHERE InvDt.InvoiceID in (Select ItemValue from dbo.fn_SplitIn2Rows_Int (@InvNos,','))
--AND InvAb.InvoiceID=InvDt.InvoiceID
--AND Items.Product_Code = InvDt.Product_Code
--And InvDt.UOM *= UOM.UOM 
--AND Items.CategoryID *= ItemCategories.CategoryID
--AND BP.Batch_Code =* InvDt.Batch_Code
group by InvDt.Product_Code, Items.ProductName, InvDt.Batch_Number,InvAb.InvoiceType,
InvDt.UOM, UOM.Description, InvDt.UOMPrice, InvDt.SalePrice,
InvDt.SaleID, Items.Track_Batches, ItemCategories.Price_Option,
ItemCategories.Track_Inventory, Isnull(BP.Free,0),
Isnull(BP.PTR,0),
InvDt.MRP,InvDt.Serial,InvDt.FlagWord, InvDT.freeSerial, 
InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, IsNull(InvDt.SCHEMEDISCPERCENT,0),  
IsNull(InvDt.SPLCATDISCPERCENT,0),InvDt.SalePriceBeforeExciseAmount, InvDt.ExciseDuty, InvDt.OtherCG_Item, InvDt.MultipleSchemeID, InvDt.TotSchemeAmount, InvDt.MultipleSplCatSchemeID, InvDt.MultipleSchemeDetails, 
InvDt.MultipleSplCategorySchDetail)
TempData Group by TaxCode order by TaxCode Desc
  
Open TaxData        
Fetch From TaxData into @Tax,@Sale_Value,@Tax_Amt
While @@Fetch_Status = 0        
Begin        
    
Set @Result =  IsNull(@Result, N'') + '|' + Cast(@Tax as nvarchar(10)) + Space(6 -len(@Tax))  
         + '|' + Space(17 -len(@Sale_Value)) + Cast(@Sale_Value as nvarchar(10))  
         + '|' + Space(10 -len(@Tax_Amt)) + Cast(@Tax_Amt as nvarchar(10))
         + '|;'
  Set @Total_Tax_Amt=@Total_Tax_Amt + @Tax_Amt
  set @Total_Sale_Value=@Total_Sale_Value+@Sale_Value

Fetch Next From TaxData into @Tax,@Sale_Value,@Tax_Amt    
End        
  
Set @Result= @Result + '|' + REPLICATE('-',35) + '|;'   
Set @Result= @Result + '|Total' 
					 + Space(19 - Len (Cast(@Total_Sale_Value as nvarchar(10)))) + Cast(@Total_Sale_Value as nvarchar(10)) + '|'
					 + Space(10 - Len (Cast(@Total_Tax_Amt as nvarchar(10)))) + Cast(@Total_Tax_Amt as nvarchar(10)) 
					 + '|;'   
Set @Result= @Result + '|' + REPLICATE('-',35) + '|;'
  
Set @Result = SubString(@Result, 3, Len(@Result) - 2)  
  
Close TaxData       

Deallocate TaxData        

Return @Result        


End

