Create Procedure Sp_Print_DandDDetail_DC(@ID Int)  
AS
Declare @ClaimStatus	int

Select @ClaimStatus = ClaimStatus From DandDAbstract Where ID = @ID
  
If @ClaimStatus = 1  
Begin
Select 
"HSNNumber" = I.HSNNumber ,
"Product_Code" = DD.Product_code, 
"ProductName" = I.ProductName ,
"UOM" = U.Description ,
"QTY" = Sum(DD.UOMTotalQty) ,
"Rate" = IsNull(DD.PTS,0) * (Select dbo.fn_Get_SelectedUOM_Conv(DD.Product_Code, DD.UOM )),  
"Amount" = Sum(DD.UOMTotalQty) * IsNull(DD.PTS,0) * (Select dbo.fn_Get_SelectedUOM_Conv(DD.Product_Code, DD.UOM ))
,"BUOMQty" = SUM(DD.TotalQuantity)
From DandDDetail DD, Items I, UOM U
Where DD.ID = @ID 
And DD.Product_code = I.Product_Code 
And DD.UOM  = U.UOM 
 Group By I.HSNNumber, DD.Product_code, I.ProductName,DD.UOM , U.Description , DD.PTS 
Order by  I.ProductName 
End
Else
Begin
Select 
"HSNNumber" = I.HSNNumber ,
"Product_Code" = DD.Product_code, 
"ProductName" = I.ProductName ,
"UOM" = U.Description ,
"QTY" = Sum(DD.UOMTotalQty) ,
"Rate" = IsNull(DD.UOMPTS ,0) ,  
"Amount" = Sum(DD.UOMTotalQty) * IsNull(DD.UOMPTS,0)
,"BUOMQty" = SUM(DD.TotalQuantity)
From DandDDetail DD, Items I, UOM U
Where DD.ID = @ID 
And DD.Product_code = I.Product_Code 
And DD.UOM  = U.UOM 
 Group By I.HSNNumber, DD.Product_code, I.ProductName, U.Description , DD.UOMPTS 
Order by  I.ProductName
End 
