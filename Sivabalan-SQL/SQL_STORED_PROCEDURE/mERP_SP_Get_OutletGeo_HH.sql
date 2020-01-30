CREATE Procedure mERP_SP_Get_OutletGeo_HH
(
@Latitude Decimal(18,6),
@Longitude Decimal(18,6),
@CustomerID nVarchar(30)
)
As
Begin

If (Select COUNT(*) from OutletGeo where Customerid = Isnull(@CustomerID,'')) = 0
Begin
Insert Into OutletGeo(CustomerID,Latitude,Longitude,ModifiedDate)
Select @CustomerID,@Latitude,@Longitude,GETDATE()
End

End
