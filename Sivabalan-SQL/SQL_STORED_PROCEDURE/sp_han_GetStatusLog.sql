Create Procedure sp_han_GetStatusLog(@OrdDetId Integer)  
As   
Declare @StatusOne as integer  
Declare @StatusTwo as integer  
  
Create Table #TempDet(OrdNo nVarchar(100),OrdProdCode nChar(30),OrdUOMID Int,  
OrdQty Decimal(18,6),FreeProdCode nChar(30),FreeItemQty Decimal(18,6),FreeItemUOMId Int)  
Insert into #TempDet  
Select SH.OrderNumber,SH.OrderedProductCode,SH.OrderedItemUOMID,SH.OrderedQty,  
SH.FreeProductCode,SH.FreeItemQty,SH.FreeitemUOMID From Scheme_details SH  
Where SH.Order_Detail_Id =  @OrdDetID   
  
Select @StatusTwo = Count(*) From  #TempDet  
  
Select @StatusOne = Count(*) From Scheme_details SH   
Where SH.OrderedProductCode = SH.OrderedProductCode  
And SH.OrderedItemUOMID = SH.OrderedItemUOMId    
And SH.OrderedQty = SH.OrderedQty   
And SH.Order_Detail_ID = @OrdDetID  
If @StatusOne = @StatusTwo  
 Select 1 'StatusFlag'  
Else  
 Select 2 'StatusFlag'  
