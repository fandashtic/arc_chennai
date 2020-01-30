CREATE PROCEDURE mERP_sp_get_InvInvalidMarginItems
(
@INVOICEID INT,
@Mode Int=0,
@GRNDate DateTime = Null
)
AS

If @GRNDate Is Null 
Set @GRNDate = GetDate()

Create Table #RecItemList (ItemOrderID Int, CategoryID Int, ParentCatID Int, Margin Decimal(18,6))
Insert Into #RecItemList (ItemOrderID, CategoryID, ParentCatID, Margin)
Select IDR.ItemOrder, ICA.CategoryID, ICB.CategoryID, 
isNull(dbo.merp_fn_Get_ProductMargin(IDR.Product_Code,@GRNDate),0)
From InvoiceDetailReceived IDR, Items I, ItemCategories ICA, ItemCategories ICB
Where IDR.InvoiceID = @INVOICEID 
And (IDR.Pending > 0 Or @Mode = 2)
And IDR.Product_Code = I.Product_Code 
And I.CategoryID = ICA.CategoryID
And ICA.ParentID = ICB.CategoryID

-- To Show the Margin not defined received Items
SELECT Distinct IDR.ForumCode , I.ProductName,0 'ExistingMargin',0 'NewMargin'
FROM InvoiceDetailReceived IDR, #RecItemList RIL, Items I
WHERE IDR.InvoiceID = @INVOICEID
And Margin = 0
And RIL.ItemOrderID = IDR.ItemOrder
And IDR.Product_Code = I.Product_Code
union
select S.Product_Code,Items.ProductName,OldMargin,Percentage 
from dbo.mERP_fn_GetNewProductMargin(@INVOICEID,@GRNDate) S,Items
where S.Product_Code=Items.Product_Code
and S.Percentage > 0 

Drop Table #RecItemList

