Create Procedure mERP_sp_GetChequesInfo_ITC(@Salesman nVarchar(50))
As
Begin
	Declare @TmpSalesman Table(SalesmanID Int, SalemanName nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
	Declare @Delimeter as nVarchar
	Set @Delimeter = char(15)

	If @Salesman = '%'
		Insert Into @TmpSalesman
		Select 0, ''
		Union
		Select SalesmanID, Salesman_Name From Salesman    
	Else    
		Insert Into @TmpSalesman
		Select SalesmanID, Salesman_Name From Salesman Where Salesman_Name = @Salesman

	Select IsNull(Count(DocumentID), 0) as [NoOfChqs], IsNull(Sum(Value), 0) as [ChqsInHand] From Collections 
	Where IsNull(Status, 0) & 192 = 0 And IsNull(PaymentMode, 0) = 1
	And IsNull(Realised, 0) Not In (1, 2, 3)
	And IsNull(SalesmanID, 0) In (Select SalesmanID From @TmpSalesman) 
End
