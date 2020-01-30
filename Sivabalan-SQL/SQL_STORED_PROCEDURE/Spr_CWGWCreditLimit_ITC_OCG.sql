Create Procedure Spr_CWGWCreditLimit_ITC_OCG
(
 @Salesman NVarChar(4000),
 @Beat NVarChar(4000),
 @CGType NVarChar(4000) = 'Regular'
)
As
Declare @Delimeter  Char(1)                      
Set @Delimeter=Char(15)                                

Create Table #TmpSalesman(SalesmanID Int)
Create Table #TmpBeat(BeatID Int)

If @Salesman = N'%'
 Insert InTo #TmpSalesman
  Select Distinct SalesmanID From Salesman
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

If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 1 And @CGType = 'Operational'
	Begin
		Select
		 IsNull(C.CustomerID,''),
		 "Customer ID" = IsNull(C.CustomerID,''),
		 "Customer Name" = IsNull(C.Company_Name,''),
		 "Category Group" = IsNull(PCGA.GroupName,''),
		 "Credit Limit (%c)" = Case IsNull(CCL.CreditLimit,-1) When -1 Then N'N/A' Else Cast(CCL.CreditLimit As NVarChar) End,
		 "Credit Term (Days)" = Case IsNull(CT.Value,-1) When -1 Then N'N/A' Else Cast(CT.Value As NVarChar) End,
		 "Max. No of Bills Outstanding" = Case IsNull(CCL.NoOfBills,-1) When -1 Then N'N/A' Else Cast(CCL.NoOfBills As NVarChar) End
		From
 CustomerCreditLimit CCL
 inner join Customer C on CCL.CustomerID = C.CustomerID
  inner join Beat_Salesman BS on  CCL.CustomerID = BS.CustomerID
inner join ProductCategoryGroupAbstract PCGA on  CCL.GroupID = PCGA.GroupID
  left outer join CreditTerm CT on  CCL.CreditTermDays = CT.CreditID
		Where
	 BS.SalesmanID In (Select SalesmanID From #TmpSalesman)
		 And BS.BeatID In (Select BeatID From #TmpBeat)
		 And Isnull(PCGA.OCGType,0) = 1
		Group By
		 C.CustomerID,C.Company_Name,PCGA.GroupName,CCL.CreditLimit,CCL.NoOfBills,CT.Value

	End
Else If @CGType = 'Regular'
	Begin
		Select
		 IsNull(C.CustomerID,''),
		 "Customer ID" = IsNull(C.CustomerID,''),
		 "Customer Name" = IsNull(C.Company_Name,''),
		 "Category Group" = IsNull(PCGA.GroupName,''),
		 "Credit Limit (%c)" = Case IsNull(CCL.CreditLimit,-1) When -1 Then N'N/A' Else Cast(CCL.CreditLimit As NVarChar) End,
		 "Credit Term (Days)" = Case IsNull(CT.Value,-1) When -1 Then N'N/A' Else Cast(CT.Value As NVarChar) End,
		 "Max. No of Bills Outstanding" = Case IsNull(CCL.NoOfBills,-1) When -1 Then N'N/A' Else Cast(CCL.NoOfBills As NVarChar) End
		From
 CustomerCreditLimit CCL
 inner join Customer C on CCL.CustomerID = C.CustomerID
  inner join Beat_Salesman BS on  CCL.CustomerID = BS.CustomerID
inner join ProductCategoryGroupAbstract PCGA on  CCL.GroupID = PCGA.GroupID
  left outer join CreditTerm CT on  CCL.CreditTermDays = CT.CreditID

		Where
		  BS.SalesmanID In (Select SalesmanID From #TmpSalesman)
		 And BS.BeatID In (Select BeatID From #TmpBeat)
		 And Isnull(PCGA.OCGType,0) = 0
		Group By
		 C.CustomerID,C.Company_Name,PCGA.GroupName,CCL.CreditLimit,CCL.NoOfBills,CT.Value
	End
Else If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 0 And @CGType = 'Operational'
	Begin
		Select NUll as "CustomerID",
		 NUll as "Customer ID" ,
		 NUll as "Customer Name" ,
		 NUll as "Category Group",
		 NUll as "Credit Limit (%c)",
		 NUll as "Credit Term (Days)",
		 NUll as "Max. No of Bills Outstanding"
	End
