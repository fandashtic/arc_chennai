Create Function mERP_fn_GetChequesInfo_ITC(@Salesman nVarchar(50),@Beat nvarchar(1000),@category nvarchar(1000))
returns Decimal(18,6)
AS
Begin
	Declare @TmpSalesman Table(SalesmanID Int, SalemanName nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
	Declare @Results Table(SalesmanID Int, BeatID Int, CategoryID Int, Amount Decimal(18,6))
	Declare @Delimeter as nVarchar
	Declare @chqValue decimal(18,6)
	Declare @Continue int  
	Declare @CategoryID int  
	Set @Continue = 1 
	Set @Delimeter = char(15)
	
	If @Salesman = '%'
		Insert Into @TmpSalesman
		Select 0, ''
		Union
		Select SalesmanID, Salesman_Name From Salesman    
	Else    
		Insert Into @TmpSalesman
		Select SalesmanID, Salesman_Name From Salesman Where Salesman_Name = @Salesman

	Insert Into @Results
	Select C.SalesmanID, C.BeatID, I.CategoryID, (Case (IsNull(Realised, 0)) When 3 Then 
	dbo.mERP_fn_get_RepresentChqAmt(C.DocumentID) Else IsNull((Value), 0) End)
	From CollectionDetail CD, Collections C,InvoiceAbstract, InvoiceDetail IDet, Items I, ChequeCollDetails ccd
	Where 
	IsNull(C.Status, 0) & 192 = 0 
	And IsNull(C.PaymentMode, 0) = 1
	And IsNull(Realised, 0) Not In (1, 2)
	And IsNull(C.SalesmanID, 0) In (Select SalesmanID From @TmpSalesman)
	And IsNull(C.BeatID, 0) In (Select BeatID From Beat Where Description = @Beat)
	And C.documentID = CD.CollectionID
	And IsNull(CD.DocumentType,0) = 4
	And CD.CollectionID = ccd.CollectionID
	And CD.DocumentID = ccd.DocumentID
	And CD.DocumentType = ccd.DocumentType
	And CD.DocumentID = Invoiceabstract.InvoiceID
	And Invoiceabstract.InvoiceID = Idet.InvoiceId
	And Idet.Product_Code = I.Product_code
	And I.CategoryID In (Select CategoryID From dbo.mERP_fn_GetLeafCategories('%', @category))
	
	Select @chqvalue = IsNull(Sum(Amount), 0) From @Results Group By SalesmanID, BeatID, CategoryID
	
	Return IsNull(@chqvalue, 0)
End
