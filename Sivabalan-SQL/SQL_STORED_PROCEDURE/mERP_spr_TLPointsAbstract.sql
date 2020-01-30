Create procedure mERP_spr_TLPointsAbstract(@TLMonth nvarchar(50), @TLType nVarchar(4000))
As
Begin

Declare @TLTypeMaster as table(TypeDesc nVarchar(200) Collate SQL_Latin1_General_CP1_CI_AS)	
Create table #tmpTLTypeRpt (RowID int Identity(1,1), TypeId Int, TypeDesc nVarchar(200) Collate SQL_Latin1_General_CP1_CI_AS, [Total No. of TL] int, [Fixed Points] Decimal(18,6),Mobility Decimal(18,6))
Declare @Delimiter as char(1)
Set @Delimiter = Char(15)
If @TLType = '%' OR @TLType = N'All TL Type'
	Insert into @TLTypeMaster
	Select TypeDesc From tbl_mERP_SupervisorType Where Active = 1 And IsNull(ReportFlag,0) = 1 
Else
	Insert into @TLTypeMaster
	Select * from dbo.sp_SplitIn2Rows(@TLType,@Delimiter)

Insert into #tmpTLTypeRpt(TypeId, TypeDesc, [Total No. of TL] , [Fixed Points] , [Mobility] )
Select TLT.TypeId, TLT.TypeDesc, Count(SalesManName) ,NULL, NULL
from tbl_mERP_SupervisorType TLT
Left Outer Join SalesMan2 TL On TLT.TypeID = TL.TypeID
Inner Join @TLTypeMaster TLM On TLT.TypeDesc = TLM.TypeDesc
Where TLT.Active = 1 And TL.Active=1 
and IsNull(TLT.ReportFlag,0) = 1 
Group By TLT.TypeId, TLT.TypeDesc
Order By TLT.TypeDesc


Insert into #tmpTLTypeRpt(TypeId, TypeDesc, [Total No. of TL] , [Fixed Points] , [Mobility] )
Select -1 as 'TLTypeID', 'Grand Total:' as TypeDesc, 
(Select Sum([Total No. of TL]) From  #tmpTLTypeRpt Where IsNull([Total No. of TL],0) > 0) as 'Total No. of TL', "Fixed Points" =NULL, "Mobility"= NULL

Select TypeId, TypeDesc as [TL Type], [Total No. of TL] , '' as [Fixed] , '' as Mobility From #tmpTLTypeRpt Order by RowID
Drop table #tmpTLTypeRpt

End
