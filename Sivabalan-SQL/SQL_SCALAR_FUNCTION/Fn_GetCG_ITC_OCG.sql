CREATE Function Fn_GetCG_ITC_OCG(@InvID As int , @CategoryType as Int = 0)
Returns nVarchar(2550)
As
Begin

Declare @GroupID As Int

Declare @GroupName As nVarchar(256)
Declare @ConGroupName as nVarchar(2550)
If @CategoryType = 0
Begin
	Declare CGN Cursor For 
	select distinct map.Categorygroup from tblcgdivmapping map, ItemCategories Div, ItemCategories SUB, ItemCategories MSKU, Items I
	where I.CategoryID=MSKU.Categoryid and MSKU.ParentID=SUB.CategoryID and SUB.ParentID=Div.CategoryID and Map.Division=Div.Category_Name
	and I.Product_Code in(Select Product_Code From InvoiceDetail Where InvoiceID = @InvID)
End
Else
Begin
	Declare CGN Cursor For 
	select distinct GRoupname from OCGItemMaster where exclusion=0 and SystemSKU in ( Select Product_Code From InvoiceDetail Where InvoiceID = @InvID)
	

End
Open CGN
Fetch From CGN Into @GroupName
While @@Fetch_Status = 0    
  Begin    
	Set @ConGroupName = IsNull(@ConGroupName, '') + ' ' + @GroupName + ' |'
    Fetch Next From CGN Into @GroupName
  End
Close CGN
DeAllocate CGN

Set @ConGroupName = Left(@ConGroupName, Len(@ConGroupName) - 1)
Return @ConGroupName

End

