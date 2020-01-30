CREATE procedure mERP_sp_get_HHSRAbs
(
@ReturnNumber nVarChar(100),
@nFlag Int,
@CatGrpID nVarchar(1000),
@SalesmanID int,
@AllgroupSalesmanId nVarchar(1000))
As
Declare @OutLetID nVarChar(50)
Declare @BillID nVarChar(50)
Declare @BeatID int
Declare @ReturnType int
Declare @SalesMan nVarChar(50)
Declare @Beat nVarChar(255)
Declare @GroupName nVarChar(500)
Declare @CustCat int
Declare @CustLocality int

Declare @InvID int
Declare @CrTerm int
Declare @BillingAddress nVarChar(255)
Declare @ShippingAddress nVarChar(255)
Declare @ADisc Decimal(18,6)
Declare @Freight Decimal(18,6)
Declare @Disc Decimal(18,6)
Declare @Memo1 nVarChar(255)
Declare @Memo2 nVarChar(255)
Declare @Memo3 nVarChar(255)
Declare @Flags int


Create table #temp(GrpID int)
Insert Into #temp
Select * from dbo.sp_splitin2Rows(@CatGrpID, ',')


Select TOP 1 
@OutLetID = OutletID,
@BillID = BillID,
-- @BeatID = BeatID,
@ReturnType = ReturnType
From Stock_Return 
Where ReturnNumber = @ReturnNumber And ReturnType = @nFlag 



Select @BeatID = BeatID from Beat_salesman where SalesmanID = @SalesmanID and CustomerID = @OutletID


-- Set @InvID = 0
-- if @BillID <> ''
-- Select @InvID = IsNull(InvoiceID,0) From InvoiceAbstract
-- Where DocumentID = dbo.gettrueval(@BillID)
-- And Status & 192 = 0

-- if @InvID > 0
-- Select @CrTerm = ISNULL(CreditTerm, 0),
-- @BillingAddress = BillingAddress, @ShippingAddress = ShippingAddress,
-- @ADisc = AdditionalDiscount, @Freight = Freight, @Disc = DiscountPercentage,
-- @Memo1 = Memo1, @Memo2 = Memo2, @Memo3 = Memo3, @Flags = Flags
-- From InvoiceAbstract Where InvoiceID = @InvID
-- Else
Select @CrTerm = ISNULL(CreditTerm, 0),
@BillingAddress = BillingAddress, @ShippingAddress = ShippingAddress,
@ADisc = 0, @Freight = 0, @Disc = 0,
@Memo1 = '', @Memo2 = '', @Memo3 = '', @Flags = 0
From Customer Where  CustomerID = @OutletID

Select @SalesMan = Salesman_Name From SalesMan Where SalesmanID = @SalesManID

Select @Beat = [Description] From Beat Where BeatID = @BeatID

Select @GroupName = dbo.mERP_fn_Get_GroupNames(@CatGrpID)

Select @CustCat = CustomerCategory, @CustLocality = IsNull(Locality,1)
From Customer Where CustomerID = @OutletID

Select "BillID" = @BillID, "SalesManID" = @SalesManID, "SalesMan" = @SalesMan,
"BeatID" = @BeatID, "Beat" = @Beat, "GroupID" = @CatGrpID, "GroupName" = @GroupName, --@AllgroupSalesmanId,
"SRType" = @ReturnType, "CustCatType" = @CustCat, "Locality" = @CustLocality,
"CreditTerm" = @CrTerm, "BillingAddress" = @BillingAddress , 
"ShippingAddress" = @ShippingAddress, "ADisc" = @ADisc, "Disc" = @Disc , 
"Freight" = @Freight, "Memo1" = @Memo1 , "Memo2" = @Memo2, "Memo3" = @Memo3, "Flags" = @Flags

Drop table #temp

