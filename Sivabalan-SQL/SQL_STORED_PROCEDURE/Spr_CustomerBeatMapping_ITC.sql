Create Procedure Spr_CustomerBeatMapping_ITC
(
 @Salesman NVarChar(4000),
 @Beat NVarChar(4000)
)
As
Declare @Delimeter  Char(1)
Set @Delimeter=Char(15)

Create Table #TmpSalesman(SalesmanID Int)
Create Table #TmpBeat(BeatID Int)

If @Salesman = N'%'
 Begin
  Insert InTo #TmpSalesman Values(0)
  Insert InTo #TmpSalesman Select Distinct SalesmanID From Salesman
 End
Else
 Insert InTo #TmpSalesman
  Select Distinct SalesmanID From Salesman Where Salesman_Name In (Select * From Dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))
            
If @Salesman = N'%' And @Beat = N'%'
 Insert InTo #TmpBeat
  Select Distinct BeatID From Beat
Else If @Salesman <> N'%' And @Beat = N'%'
 Insert InTo #TmpBeat
  Select BeatID From Beat_Salesman Where SalesmanID In (Select SalesmanID From #TmpSalesman) Group By BeatID
Else
 Insert InTo #TmpBeat
  Select BeatID From Beat Where Description In (Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))

Select
 Distinct C.CustomerID,
 "Customer ID" = C.CustomerID,
 "Customer Name" = C.Company_Name,
 "Beat" = B.[Description],
 "Default Beat" =
  Case IsNull((Select DefaultBeatID From Customer Where DefaultBeatID = B.BeatID And CustomerID = C.CustomerID),0)  
   When 0 then N'No'
   Else N'Yes'
  End
From
 Customer C,Beat B,Beat_Salesman BS
Where
 C.CustomerID = BS.CustomerID
 And B.BeatID = BS.BeatID
 And IsNull(BS.SalesmanID,0) In (Select SalesmanID From #TmpSalesman)
 And BS.BeatID In (Select BeatID From #TmpBeat)


