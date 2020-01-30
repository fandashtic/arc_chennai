CREATE procedure mERP_sp_Update_HHSRStatus 
(
@ReturnNumber nVarChar(100),
@InvID Integer,
@nFlag Int,
@CatGrpID nVarchar(1000)
)
As

Create table #temp(GrpID int)
Insert Into #temp
Select * from dbo.sp_splitin2Rows(@CatGrpID, ',')


Update Stock_Return Set Processed = 1 
Where ReturnNumber = @ReturnNumber And ReturnType = @nFlag 
-- And CategoryGroupID = @CatGrpID
And CategoryGroupID In (Select GrpID from #temp)

Drop table #Temp
