CREATE Procedure mERP_sp_Update_Merchandise(@CustID nVarChar(50),@Merchandises nVarchar(4000))
As
Begin
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(44)
Create Table #TempMerch (Merch integer)

Delete from CustMerchandise where CustomerID = @CustID

If @Merchandises = '%'
Begin
	Insert InTo CustMerchandise Select @CustID,MerchandiseID from Merchandise
End
Else
Begin
	Insert InTo #TempMerch Select * from dbo.sp_SplitIn2Rows(@Merchandises, @Delimeter)
	Insert InTo CustMerchandise Select @CustID,MerchandiseID from Merchandise
  Where MerchandiseID in (Select Merch from #TempMerch)
End

End
