CREATE procedure sp_ser_cancelableinvoice(@InvoiceID as int)
as
Declare @Deposited int, @IncludedInCollection as int 
Declare @JobcardExists int, @EstimationExists as int 
/* Included in Explicit Collection */
Select @IncludedInCollection = Count(*) from CollectionDetail 
inner Join Collections on Collections.DocumentID = CollectionDetail.CollectionID and (Isnull(Collections.Status, 0) & 192) = 0 
Where CollectionDetail.DocumentID = @InvoiceID and DocumentType = 12 and 
CollectionID not In (Select Isnull(PaymentDetails, 0) from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID)

/* Check for Deposited Collection */
Select @Deposited = Count(*) from Collections 
	Where DocumentID In (Select (Case when PaymentMode > 0 then Isnull(PaymentDetails, 0) else 0 end) 
			from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID) 
and ((IsNull(OtherDepositID, 0) <> 0) or ((IsNull(Status, 0) & 1) <> 0))

/* If the selected Invoice is from Jobcard then Cancellation will open the Jobcard. 
this should be restricted in case of existing active transaction for the item spec1 included 
in the current selected invoice */
Select d.Product_Specification1 spec1 into #tempItemspec1 from ServiceinvoiceAbstract a 
Inner Join ServiceinvoiceDetail d On d.ServiceInvoiceID = a.ServiceInvoiceID and d.type = 0
Where Isnull(a.status, 0) & (1 | 8) <> 0 and a.ServiceInvoiceID = @InvoiceID

Select @JobcardExists = Count(*) from JobcardAbstract a 
Inner Join JobcardDetail d On d.jobcardID = a.JobcardID and d.Type = 0
Inner Join #tempItemSpec1 s On s.spec1 = d.Product_Specification1
where Isnull(a.Status, 0) & 192 = 0 and Isnull(ServiceInvoiceID, 0) = 0  

Select @EstimationExists = Count(*) from EstimationAbstract a
Inner Join EstimationDetail d On a.EstimationId = d.EstimationID and 
	d.Product_Specification1 in (Select spec1 from #tempItemSpec1)
Where Isnull(a.Status, 0) & 128 = 0  


Select Isnull(@JobcardExists, 0) + Isnull(@EstimationExists, 0) + 
IsNull(@IncludedInCollection, 0) + IsNull(@Deposited, 0) + 
Isnull((Select Count(*) from Coupon 
	Where CollectionID In (Select (Case when PaymentMode > 0 then PaymentDetails else 0 end) 
			from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID)
	and Isnull(CouponDepositID, 0) <> 0), 0) 


