CREATE Procedure sp_ser_updatedirinvoicebase(@InvoiceID  int) 
as
Declare @InvoiceDocID int 
Declare @EstimationDocID int 
Declare @JobCardDocID int 
Declare @IssueDocID int 

Declare @EstimationID int 
Declare @JobCardId int 
Declare @IssueID int 
Declare @JobcardDate datetime 
Declare @InvoiceDate datetime
Declare @DocRef nvarchar(100)  
Declare @DocumentType varchar(100)  
Declare @DocSerialType varchar(100) 
Declare @IssueDocRef nvarchar(100)  
Declare @IssueDocumentType varchar(100)  
Declare @IssueDocSerialType varchar(100) 
Declare @UserName nvarchar(100)
Declare @LastCount nvarchar(100) 
Declare @IssueLastCount nvarchar(100) 
Declare @Prefix nvarchar(100)
Declare @DocumentID nvarchar(100)
Declare @IssueDocumentID nvarchar(100)
Declare @Locality int 
Select @Locality = IsNull(c.Locality , 1) from Customer c 
	Inner Join ServiceInvoiceAbstract a on c.CustomerID = a.CustomerID
	Where a.ServiceInvoiceID = @InvoiceID

/* updating status 8 for direct invoice */
Update a Set Status = (Isnull(status,0) | 8), 
a.VatTaxAmount_Spares = (case @Locality When 2 then 0 Else 
	(Select Sum(Isnull(d.LSTPayable, 0) + Isnull(d.CSTPayable, 0)) 
	from ServiceInvoiceDetail d 
	Where d.ServiceInvoiceID = a.ServiceInvoiceId and 
		Isnull(d.Vat_Exists, 0) = 1 and Isnull(d.SpareCode, 0) <> '')
	end)
from ServiceInvoiceAbstract a Where a.ServiceInvoiceID = @InvoiceID

Select @JobcardId = JobcardID, @InvoiceDocID = DocumentID, @InvoiceDate = ServiceInvoiceDate 
from ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceID 

-- If @Locality = 2 begin Set @CSTPayable = @SalesTaxAmount end
-- Else begin Set @LSTPayable = @SalesTaxAmount end 

/* Estimation Transaction */ 
begin tran
  update DocumentNumbers set DocumentID = DocumentID + 1, 
				@EstimationDocID = DocumentID where DocType = 100

	select top 1 @DocumentType = Documenttype from TransactionDocNumber 
	Inner Join DocumentUsers On TransactionDocNumber.serialno = Documentusers.serialno  
	where TransactionType = 100 and TransactionDocNumber.Active = 1 
	and Documentusers.username = @UserName
	If isnull(@DocumentType, '') = '' 

	begin 
		select top 1 @DocumentType = Documenttype
		from TransactionDocNumber 
		where TransactionType = 100 and TransactionDocNumber.Active = 1 
	end 
	if isnull(@DocumentType, '') <> '' 
	begin  	
		BEGIN TRAN    
			UPDATE TransactionDocNumber SET LastCount = LastCount + 1   
			WHERE TransactionType = 100 And DocumentType=@DocumentType    
			SELECT @LastCount = LastCount - 1 FROM TransactionDocNumber 
			WHERE TransactionType = 100 And DocumentType=@DocumentType 
		COMMIT TRAN
		set @DocRef = dbo.fn_ser_GetTransactionSerial(100, @DocumentType, @LastCount)	
	end 
	if isnull(@DocRef, '') = ''
	begin 
		select @Prefix = Prefix from VoucherPrefix where [TranID]= 'JOBESTIMATION'
		Set @DocRef = isnull(@Prefix, 'JE') + Cast(@EstimationDocID as nvarchar(20))
	end

set @DocSerialType = isnull(@DocumentType, '')
commit tran
Insert into EstimationAbstract 
(DOCUMENTID, ESTIMATIONDATE, CustomerID, STATUS, Username,DocRef,DocSerialType)   
Select @EstimationDocID, ServiceInvoiceDate, CustomerID, 128, Username, @DocRef,@DocSerialType from 
ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceID 

Set @EstimationID = @@Identity 

Insert into Estimationdetail (ESTIMATIONID, PRODUCT_CODE, Product_Specification1, Type,  
TASKID, SPARECODE, Price, QUANTITY, LSTPayable, CSTPAYABLE, SALESTAX, TaxSuffered_Percentage,
TAXSUFFERED, UOM, uomQty, UOMPrice, ServiceTax_Percentage, ServiceTax, TASKDURATION, AMOUNT, 
NETVALUE) 
Select @EstimationID, d.PRODUCT_CODE, d.Product_Specification1, d.Type, 
d.TASKID, d.SPARECODE, d.EstimatedPrice, d.QUANTITY, d.LSTPayable, d.CSTPayable, 
	d.SaleTax, d.Tax_SufferedPercentage, d.TAXSUFFERED, d.UOM, d.uomQty, 
d.EstimatedPrice * (d.QUANTITY/d.uomQty) , d.ServiceTax_Percentage, d.ServiceTax, 
ti.TASKDURATION, (d.EstimatedPrice * IsNull(d.Quantity, 1)),
(case 
when  type = 2 and IsNull(d.TaskID,'') <> '' and IsNull(d.SpareCode,'') ='' then
	d.EstimatedPrice + (d.EstimatedPrice * IsNull(d.ServiceTax_Percentage,0)/100) 
when type = 3 or IsNull(d.SpareCode,'') <> '' then 
-- 	((d.Quantity * d.EstimatedPrice) + (((d.Quantity * d.EstimatedPrice) * d.Tax_SufferedPercentage) /100) 
-- 	+ (((d.Quantity * d.EstimatedPrice) * d.SaleTax) /100)) 
	((d.Quantity * d.EstimatedPrice) + (((d.Quantity * d.EstimatedPrice) * d.Tax_SufferedPercentage) /100) 
	+ ((((d.Quantity * d.EstimatedPrice) + (((d.Quantity * d.EstimatedPrice) * d.Tax_SufferedPercentage) /100)) * d.SaleTax) /100))
end)
from ServiceInvoiceDetail d
left outer Join Task_Items ti on ti.Product_Code = d.Product_Code and ti.TaskId = d.TaskId
Where d.ServiceInvoiceID = @InvoiceID and d.Type <> 0

/* JobCard Transaction  (Min date of taskallocation and estimationid updation)*/
Select @JobcardDate = Min(StartTime) from JobcardTaskAllocation where JobCardID = @JobcardID

update JobcardAbstract Set JobCardDate = IsNull(@Jobcarddate, @Invoicedate), 
		EstimationID = @EstimationId, 
		@JobCardDocID = DocumentID 
Where JobcardId = @JobcardId 

/* Item Information */
Update Item_Information Set Product_Status = 0, LastServiceDate = Getdate(),
LastModifiedDate = getdate(), LastJobCardID = @JobcardID
where Product_Specification1 in (Select Product_Specification1 from ServiceInvoiceDetail 
Where ServiceInvoiceId = @InvoiceId)

/* Updating ItemInformation_Transactions -- jobcard and estimation*/
Insert into Iteminformation_Transactions 
(DocumentID, DocumentType, Product_Specification2, Product_Specification3, 
Product_Specification4, Product_Specification5, Color, DateofSale, SoldBy)

Select J.SerialNo, 2, Product_Specification2, Product_Specification3, Product_Specification4, 
Product_Specification5, Color, i.DateofSale, SoldBy from Item_Information i 
Inner Join ServiceInvoiceDetail d on d.Product_Specification1 = i.Product_Specification1 and 
d.Product_Code = i.Product_Code and d.type = 0 
Inner Join (Select JD.SerialNo, JD.Product_Specification1 from JobcardDetail JD Where 
	JD.JobcardId = @JobcardId and JD.Type = 0) J On J.Product_Specification1 = d.Product_Specification1 
Where d.ServiceinvoiceID = @InvoiceId and
(Isnull(Product_Specification2, '') <> '' or Isnull(Product_Specification3, '') <> '' or
Isnull(Product_Specification4, '') <> '' or Isnull(Product_Specification5, '') <> '' or
Isnull(i.Color, 0) <> 0 or i.DateofSale is not Null or Isnull(i.SoldBy, '') <> '')

Insert into Iteminformation_Transactions 
(DocumentID, DocumentType, Product_Specification2, Product_Specification3, 
Product_Specification4, Product_Specification5, Color, DateofSale, SoldBy)
Select E.SerialNo, 1, Product_Specification2, Product_Specification3, Product_Specification4, 
Product_Specification5, Color, i.DateofSale, SoldBy from Item_Information i 
Inner Join ServiceInvoiceDetail d on d.Product_Specification1 = i.Product_Specification1 and 
d.Product_Code = i.Product_Code and d.type = 0 
Inner Join (Select min(ED.SerialNo) 'SerialNo', ED.Product_Specification1 from EstimationDetail ED 
	Where ED.EstimationID = @EstimationID Group by ED.Product_Specification1) E 
On E.Product_Specification1 = d.Product_Specification1 and 
(Isnull(Product_Specification2, '') <> '' or Isnull(Product_Specification3, '') <> '' or
Isnull(Product_Specification4, '') <> '' or Isnull(Product_Specification5, '') <> '' or
Isnull(i.Color, 0) <> 0 or i.DateofSale is not Null or Isnull(i.SoldBy, '') <> '')

Where d.ServiceinvoiceID = @InvoiceId

If not Exists(Select * from ServiceinvoiceDetail Where ServiceInvoiceId = @InvoiceId and 
				Isnull(SpareCode, '') <> '') GOTO ALL_UPDATED

/* Issue Transaction */ 
begin tran
  update DocumentNumbers set DocumentID = DocumentID + 1, 
 			@IssueDocID = DocumentID where DocType = 102
commit tran
	select top 1 @IssueDocumentType = Documenttype from TransactionDocNumber 
	Inner Join DocumentUsers On TransactionDocNumber.serialno = Documentusers.serialno  
	where TransactionType = 102 and TransactionDocNumber.Active = 1 
	and Documentusers.username = @UserName
	If isnull(@IssueDocumentType, '') = '' 
	begin 
		select top 1 @IssueDocumentType = Documenttype
		from TransactionDocNumber 
		where TransactionType = 102 and TransactionDocNumber.Active = 1 
	end 
	if isnull(@IssueDocumentType, '') <> '' 
	begin  	
		BEGIN TRAN    
			UPDATE TransactionDocNumber SET LastCount = LastCount + 1   
			WHERE TransactionType = 102 And DocumentType = @IssueDocumentType    
			SELECT @IssueLastCount = LastCount - 1 FROM TransactionDocNumber 
			WHERE TransactionType = 102 And DocumentType = @IssueDocumentType 
		COMMIT TRAN
	end 
      		set @IssueDocRef = dbo.fn_ser_GetTransactionSerial(102, @IssueDocumentType, @IssueLastCount)	 
	if isnull(@IssueDocRef, '') = ''
	begin 
		select @Prefix = Prefix from VoucherPrefix where [TranID]= 'ISSUESPARES'  
		Set @IssueDocRef = isnull(@Prefix, 'IS') + Cast(@IssueDocID as nvarchar(20))
	end
set @IssueDocSerialType = isnull(@IssueDocumentType, '')
/* Issue Transaction */
Insert into IssueAbstract (IssueType, IssueDate, DOCUMENTID, JobCardID, Username,DocRef,DocSerialType) 
Select 1, ServiceInvoiceDate, @IssueDocID, @JobCardID, Username,@IssueDocRef,@IssueDocSerialType
from ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceId  
Set @IssueId = @@Identity 

Declare issuedet Cursor KEYSET for 
(Select d.PRODUCT_CODE, d.Product_Specification1, d.SPARECODE, d.BATCH_CODE,
	d.Batch_Number, d.WARRANTY Warranty, d.WARRANTYNO WarrantyNO, 
	d.DATEOFSALE DateOfSale,
	d.UOM, d.uomQty, d.UOMPrice, Tax_SufferedPercentage, SaleTax, d.QUANTITY, Price, 
	InvoiceTax.TaxCode, d.TaskID, IsNUll(b.PurchasePrice, IsNull(Items.Purchase_Price,0)), 
	d.claim_Price, d.Vat_Exists, d.CollectTaxSuffered_Spares, d.SerialNo, j.InspectedBy
from ServiceInvoiceDetail d 
Inner Join JobcardDetail j On j.JobCardId = @JobcardId and j.Product_Code = d.PRODUCT_CODE and 
	j.Product_Specification1 = d.Product_Specification1 and j.Type = 0
Left outer Join 
	(Select Distinct t.SerialNo, t.TaxCode from ServiceInvoiceTaxComponents t
	where t.SerialNo in (Select tc.SerialNo from ServiceInvoiceDetail tc
	Where tc.ServiceInvoiceId = @InvoiceID)) InvoiceTax 
On InvoiceTax.SerialNo = d.SerialNo 
Left outer Join Batch_Products b On b.Batch_Code = d.BATCH_CODE
Inner Join Items On Items.PRODUCT_CODE = d.PRODUCT_CODE 
Where d.ServiceInvoiceID = @InvoiceId and IsNull(d.SPARECODE,'') <> '') 

Declare @ProductCode  nvarchar(50)
Declare @Spec1  nvarchar(255)
Declare @SpareCode  nvarchar(50)
Declare @Batch_Code  int 
Declare @Batch_Number  nvarchar(50)
Declare @Warranty  int 
Declare @WarrantyNo  nvarchar(50)
Declare @Dateofsale  datetime
Declare @UOM  int
Declare @UOMqty  decimal(18,2)
Declare @UOMPrice  decimal(18,2)
Declare @TaxSufferedPer  decimal(18,6)
Declare @Saletax  decimal(18,6)
Declare @Quantity  decimal(18,2)
Declare @Price  decimal(18,2)
Declare @TaxId  int 
Declare @SerialNo  int 
Declare @TaskID  varchar(15)
Declare @PurchasePrice  decimal(18,2)
Declare @ClaimPrice decimal(18, 6)
Declare @VatExists int
Declare @CollectTaxSuffered int 
Declare @InvdetSerialNo int
Declare @PersonnelID varchar(100)
Open issuedet 
Fetch next from issuedet into @ProductCode, @Spec1, @SpareCode, @Batch_Code, 
@Batch_Number, @Warranty, @WarrantyNo, @Dateofsale, @UOM, @UOMqty, @UOMPrice, 
@TaxSufferedPer, @Saletax, @Quantity, @Price, @TaxId, @TaskID, @PurchasePrice, 
@ClaimPrice, @VatExists, @CollectTaxSuffered, @InvdetSerialNo, @PersonnelID

While @@Fetch_status = 0 
begin
  /* JobCardSpares */ 
  Insert into JobcardSpares (JobCardID, Product_Code, Product_Specification1, SpareCode, UOM, 
  Qty, PendingQty, SpareStatus, Warranty, WarrantyNo, DateofSale, TaskID) Values
  (@jobcardId, @ProductCode, @Spec1, @SpareCode, @UOM, @UOMQty, 0, 1, 
  @Warranty, @WarrantyNo, @DateofSale, @TaskID) 
  	
  Set @SerialNo = @@Identity  /* JobCardSpares for referenceID*/ 

  Insert into Issuedetail (IssueID, PRODUCT_CODE, Product_Specification1, SPARECODE, 
  BATCH_CODE, Batch_Number, WARRANTY, WARRANTYNO, DATEOFSALE, UOM, uomQty, SALEPRICE, 
  TaxSuffered_Percentage, SaleTax_Percentage, IssuedQty, UOMPrice, TaxID, ReferenceID, 
  PurchasePrice, Claim_Price, Vat_Exists, CollectTaxSuffered_Spares, PersonnelID) 
  Values 
  (@IssueID, @ProductCode, @Spec1, @SpareCode, @Batch_Code, @Batch_Number, @Warranty, 
  @WarrantyNo, @Dateofsale, @UOM, @UOMqty, @Price, @TaxSufferedPer, @Saletax, @Quantity, 
  @UOMPrice, @TaxId, @SerialNo, @PurchasePrice, @ClaimPrice, @VatExists, @CollectTaxSuffered, 
  @PersonnelID)

  Set @SerialNo = @@Identity /* Issuedetail serialno */
  /* Updating Issue serial in ServiceInvoiceDetail */
  Update ServiceInvoiceDetail Set Issue_Serial = @SerialNo Where SerialNo = @InvdetSerialNo 	
  if (isnull(@Price, 0) > 0)
  begin
    Insert into IssueTaxComponent (SerialNo, 
    TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
    Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
    ((@Quantity * @Price) * (sp_Percentage / 100)) From taxcomponents 
    Where Tax_Code = @TaxId and 
    Isnull(LST_Flag, 0) = (Case Isnull(@Locality, 0) when 2 then 0 else 1 end)
  end

  Fetch next from issuedet into @ProductCode, @Spec1, @SpareCode, @Batch_Code, 
  @Batch_Number, @Warranty, @WarrantyNo, @Dateofsale, @UOM, @UOMqty, @UOMPrice, 
  @TaxSufferedPer, @Saletax, @Quantity, @Price, @TaxId, @TaskID, @PurchasePrice, @ClaimPrice, 
  @VatExists, @CollectTaxSuffered, @InvdetSerialNo, @PersonnelID
end 

Close issuedet 
deallocate issuedet

/* Update service invoice detail issueid */
Update serviceinvoicedetail set issueid = @issueid 
where serviceinvoiceid = @invoiceId and Isnull(sparecode, '') <> ''

ALL_UPDATED:
/* Returning value
--Select @JobcardId, @IssueID, @EstimationID, @InvoiceID, @InvoiceDocID, @EstimationDocID, @JobCardDocID, @IssueDocID 
 */
Select @InvoiceDocID invdoc, @JobCardDocID jobdoc


