CREATE Procedure Sp_GetmarkermasterID_HH
(
@Market_District Nvarchar(250),
@CustomerID nVarchar(30)
)
As

Declare @Market nVarchar(255)
Declare @MarketID Int

Begin

Select @Market = ItemValue FROM dbo.sp_splitin2Rows(@Market_District,'-') order by 1 desc

Select @MarketID = MMID from MarketInfo where Marketid = @Market

If (Select COUNT(*) from CustomerMarketInfo where CustomerCode = @CustomerID) = 0
Begin
Insert Into CustomerMarketInfo(MMID,CustomerCode,Active,CreationDate)
Select @MarketID,@CustomerID,1,Getdate()
End


End
