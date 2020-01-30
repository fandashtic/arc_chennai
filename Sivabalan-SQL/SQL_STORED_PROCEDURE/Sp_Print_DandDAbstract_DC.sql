
Create Procedure Sp_Print_DandDAbstract_DC(@ID Int)  
AS
Declare @ClaimStatus	int

Select @ClaimStatus = ClaimStatus From DandDAbstract Where ID = @ID

Declare @TotalAmt Decimal(18,6)
Declare @ItemCount Int
Select @TotalAmt=SUM(DD.TotalQuantity * DD.PTS)  From DandDDetail DD  Where  DD.ID = @ID  

If @ClaimStatus = 1  
Begin
	Select   @ItemCount = Count(*) From 
	(Select I.HSNNumber, DD.Product_code, I.ProductName,DD.UOM , U.Description , DD.PTS From DandDDetail DD, Items I, UOM U
Where DD.ID = @ID 
And DD.Product_code = I.Product_Code 
And DD.UOM  = U.UOM 
 Group By I.HSNNumber, DD.Product_code, I.ProductName,DD.UOM , U.Description , DD.PTS ) DandDDet
 End
Else
Begin
	Select   @ItemCount = Count(*) From 
	(Select I.HSNNumber, DD.Product_code, I.ProductName, U.Description , DD.UOMPTS From DandDDetail DD, Items I, UOM U
Where DD.ID = @ID 
And DD.Product_code = I.Product_Code 
And DD.UOM  = U.UOM 
 Group By I.HSNNumber, DD.Product_code, I.ProductName, U.Description , DD.UOMPTS ) DandDDet
End
 
Select 
"Head1" = 'DELIVERY CHALLAN',
"Head2" = '(Under Rule 55(1)(c) of the CGST Rules, 2017 and corresponding SGST Rules)',
"WD Name" = S.OrganisationTitle,
"WD GSTIN" =  S.GSTIN ,
"WD PAN" = S.PANNumber ,
"WD Address" = S.BillingAddress ,
"WD StateCode" = (Select SC.ForumStateCode From StateCode SC Where SC.StateID = S.BillingStateID) ,
"WD StateName" = (Select SC.StateName From StateCode SC Where SC.StateID = S.BillingStateID) ,
"Task Number" = DocumentID ,
"Date" = ClaimDate ,
"Vendor Name" = 'ITC Limited, C/o' ,
"C/o Name" = DA.CustomerName ,
"C/o Addres" = DA.CustomerAddress ,
"Cust GSTIN" = C.GSTIN ,
"Cust PAN" = C.PANNumber ,
"Net Amount Payable" = @TotalAmt , 
"Legend" = DA.LegendInfo ,
"ITEM COUNT" = @ItemCount
From DandDAbstract DA ,Customer C, Setup S
Where DA.ID = @ID  and DA.CustomerID = C.CustomerID 
