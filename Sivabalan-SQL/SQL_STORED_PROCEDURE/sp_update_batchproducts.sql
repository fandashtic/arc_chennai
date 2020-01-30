
Create procedure dbo.sp_update_batchproducts(@itemcode nvarchar(50),@vtb int,@pkd int)
as
Declare @PriceOption Int
Declare @DEFAULT As NVarchar(50)
Declare @TrackPKD as nVarchar(50)

--Procedure to Update batch Products

Set @DEFAULT = dbo.LookupDictionaryItem(N'Default', Default)

if(@pkd=1)
update batch_products set pkd=dbo.StripDateFromTime(getdate()) where product_code=@itemcode and isnull(pkd,0)=0

if(@vtb=1)
Begin

Select @TrackPKD = IsNull(Cast(PKD as varchar),'') From Batch_Products Where product_code=@itemcode and IsNull(batch_number,N'')=N''

If @TrackPKD = ''
Begin
update batch_products set batch_number = @DEFAULT
where product_code=@itemcode and IsNull(batch_number,N'')=N''
Update DD Set DD.Batch_Number = @DEFAULT From DandDDetail DD
Join DandDAbstract DA On DA.ID = DD.ID  And DA.ClaimStatus in(1,2)
Where DD.product_code=@itemcode and IsNull(DD.Batch_Number,N'')=N''
End
Else
Begin
Select @TrackPKD = Case When Len(DatePart(MM , GetDate())) = 1  Then  '0' + Cast( DatePart(MM , GetDate()) as varchar)
Else Cast( DatePart(MM , GetDate()) as varchar)  End
+ '/' + Cast(DatePart(YYYY, GetDate()) as varchar)

update batch_products set batch_number =  @TrackPKD
where product_code=@itemcode and IsNull(batch_number,N'')=N''
Update DD Set DD.Batch_Number = @TrackPKD From DandDDetail DD
Join DandDAbstract DA On DA.ID = DD.ID  And DA.ClaimStatus in(1,2)
Where DD.product_code=@itemcode and IsNull(DD.Batch_Number,N'')=N''
End
End

select @priceOption = IsNull(ItemCategories.price_option, 0)
from items, ItemCategories
where items.CategoryId = ItemCategories.CategoryId
And items.Product_Code = @Itemcode
If @PriceOption = 0
Begin
Update Batch_Products set SalePrice = (Select Sale_Price from
items where Product_code like @ItemCode )Where
Product_code = @ItemCode And isnull(free,0) <> 1
End

