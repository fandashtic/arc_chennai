CREATE Procedure [dbo].[sp_acc_prn_Ledger_GetdrillCount] (@DocRef Int, @DocType INT,@Info nvarchar(4000) = Null)    
As    
Declare @RETAILINVOICE INT    
Declare @RETAILINVOICEAMENDMENT INT    
Declare @RETAILINVOICECANCELLATION INT    
Declare @INVOICE INT    
Declare @INVOICEAMENDMENT INT    
Declare @INVOICECANCELLATION INT    
Declare @SALESRETURN INT    
Declare @BILL INT    
Declare @BILLAMENDMENT INT    
Declare @BILLCANCELLATION INT    
Declare @PURCHASERETURN INT    
Declare @PURCHASERETURNCANCELLATION INT    
Declare @COLLECTIONS INT    
Declare @DEPOSITS INT    
Declare @BOUNCECHEQUE INT    
Declare @REPOFBOUNCECHEQUE INT    
Declare @PAYMENTS INT    
Declare @PAYMENTCANCELLATION INT    
Declare @AUTOENTRY INT    
Declare @DEBITNOTE INT    
Declare @CREDITNOTE INT    
Declare @CLAIMSTOVENDOR INT    
Declare @CLAIMSSETTLEMENT INT    
Declare @CLAIMSCANCELLATION INT    
Declare @COLLECTIONCANCELLATION INT    
Declare @MANUALJOURNAL INT    
Declare @ARV_AMENDMENT INT    
Declare @APV_AMENDMENT INT    
    
Declare @MANUALJOURNALINVOICE int    
Declare @MANUALJOURNALSALESRETURN int    
Declare @MANUALJOURNALBILL int    
Declare @MANUALJOURNALPURCHASERETURN int    
Declare @MANUALJOURNALCOLLECTIONS int    
Declare @MANUALJOURNALPAYMENTS int    
Declare @MANUALJOURNALDEBITNOTE int    
Declare @MANUALJOURNALCREDITNOTE int    
Declare @MANUALJOURNALOLDREF int    
    
Declare @MANUALJOURNALAPV int    
Declare @MANUALJOURNALARV int    
Declare @MANUALJOURNALOTHERPAYMENTS int    
Declare @MANUALJOURNALOTHERRECEIPTS int    
    
Declare @MANUALJOURNAL_NEWREFERENCE int    
Declare @MANUALJOURNAL_CLAIMS int    
    
Declare @ARV INT    
Declare @ARVCANCELLATION INT    
Declare @APV INT    
Declare @APVCANCELLATION INT    
    
Declare @APVDETAIL INT    
Declare @ARVDETAIL INT    
    
Declare @STOCKTRANSFERIN INT    
Declare @STOCKTRANSFEROUTAMENDMENT int        
Declare @STOCKTRANSFEROUTCELLATION int        

Declare @STOCKTRANSFEROUT INT    
Declare @STOCKTRANSFERINAMENDMENT int        
Declare @STOCKTRANSFERINCANCELLATION int        
    
Declare @DISPATCH INT    
Declare @DISPATCHAMENDMENT INT    
Declare @DISPATCHCANCELLATION INT    
    
Declare @GRN INT    
Declare @GRNAMENDMENT INT    
Declare @GRNCANCELLATION INT    
Declare @INTERNALCONTRA INT    
Declare @INTERNALCONTRACANCELLATION INT    
Declare @INTERNALCONTRADETAIL INT    
Declare @COLLECTIONAMENDMENT INT    
Declare @PAYMENT_AMENDMENT INT    
Declare @PURCHASERETURN_AMENDMENT INT    
Declare @PaymentType int    
Declare @ISSUE_SPARES INT            
Declare @ISSUE_SPARES_CANCEL INT            
Declare @ISSUE_SPARES_RETURN INT            
Declare @SERVICE_INVOICE INT            
Declare @SERVICE_INVOICE_CANCEL INT            


Set @RETAILINVOICE = 1    
Set @RETAILINVOICEAMENDMENT = 2    
Set @RETAILINVOICECANCELLATION =3    
Set @INVOICE =4    
Set @INVOICEAMENDMENT = 5    
Set @INVOICECANCELLATION = 6    
Set @SALESRETURN = 7    
Set @BILL = 8    
Set @BILLAMENDMENT = 9    
Set @BILLCANCELLATION = 10    
Set @PURCHASERETURN = 11    
Set @PURCHASERETURNCANCELLATION = 12    
Set @COLLECTIONS = 13    
Set @DEPOSITS =14    
Set @BOUNCECHEQUE = 15    
Set @REPOFBOUNCECHEQUE = 16    
Set @PAYMENTS = 17    
Set @PAYMENTCANCELLATION = 18    
Set @AUTOENTRY = 19    
Set @DEBITNOTE = 20    
Set @CREDITNOTE = 21    
Set @CLAIMSTOVENDOR = 22    
Set @CLAIMSSETTLEMENT = 23    
Set @CLAIMSCANCELLATION = 24    
Set @COLLECTIONCANCELLATION = 25    
Set @MANUALJOURNAL = 26    
    
Set @MANUALJOURNALINVOICE =28    
Set @MANUALJOURNALSALESRETURN =29    
Set @MANUALJOURNALBILL =30    
Set @MANUALJOURNALPURCHASERETURN =31    
Set @MANUALJOURNALCOLLECTIONS =32    
Set @MANUALJOURNALPAYMENTS =33    
Set @MANUALJOURNALDEBITNOTE =34    
Set @MANUALJOURNALCREDITNOTE =35    
Set @MANUALJOURNALOLDREF =37    
    
Set @APV =46    
Set @APVCANCELLATION =47    
Set @ARV = 48    
Set @ARVCANCELLATION =49    
    
Set @APVDETAIL =50    
Set @ARVDETAIL =51    
    
Set @STOCKTRANSFERIN = 54    
Set @STOCKTRANSFERINAMENDMENT=69    
Set @STOCKTRANSFERINCANCELLATION=67    

Set @STOCKTRANSFEROUT = 55    
Set @STOCKTRANSFEROUTAMENDMENT=70    
Set @STOCKTRANSFEROUTCELLATION=68    
    
Set @MANUALJOURNALAPV =60    
Set @MANUALJOURNALARV =61    
Set @MANUALJOURNALOTHERPAYMENTS =62    
Set @MANUALJOURNALOTHERRECEIPTS =63    
    
Set @DISPATCH = 44    
Set @DISPATCHAMENDMENT = 71    
Set @DISPATCHCANCELLATION =45    
    
Set @GRN = 41    
Set @GRNAMENDMENT = 66    
Set @GRNCANCELLATION = 42    
    
Set @INTERNALCONTRA = 74    
Set @INTERNALCONTRACANCELLATION = 75    
Set @INTERNALCONTRADETAIL = 76    
Set @COLLECTIONAMENDMENT=77    
Set @PAYMENT_AMENDMENT =  78    
    
Set @MANUALJOURNAL_NEWREFERENCE = 81    
Set @MANUALJOURNAL_CLAIMS = 82    
Set @PURCHASERETURN_AMENDMENT = 73    
Set @ARV_AMENDMENT = 83    
Set @APV_AMENDMENT = 84    

Set @ISSUE_SPARES=85            
Set @ISSUE_SPARES_CANCEL=86            
Set @ISSUE_SPARES_RETURN=87            
Set @SERVICE_INVOICE=88            
Set @SERVICE_INVOICE_CANCEL=89            
    
Declare @PaymentMode INT,@CustomerID nVarchar(30),@VendorID nVarchar(30)    
Declare @SPECIALCASE2 INT    
SET @SPECIALCASE2=5 --Restrict the link after leaf level    
    
set dateformat dmy    

Declare @Version Int
Set @Version= dbo.sp_acc_getversion()
    
If @DocType= @RETAILINVOICE OR @DocType=@RETAILINVOICEAMENDMENT OR @DocType=@RETAILINVOICECANCELLATION     
   OR @DocType= @INVOICE OR @DocType=@INVOICEAMENDMENT OR @DocType=@INVOICECANCELLATION OR @DocType=@SALESRETURN     
 OR @Doctype=@MANUALJOURNALINVOICE OR @Doctype=@MANUALJOURNALSALESRETURN    
Begin    
	DECLARE @ADDNDIS AS FLOAT
	DECLARE @TRADEDIS AS FLOAT
	-- -- DECLARE @SPECIALCASE2 INT
	-- -- SET @SPECIALCASE2=5
	SELECT @ADDNDIS = AdditionalDiscount, @TRADEDIS = DiscountPercentage FROM InvoiceAbstract
	WHERE InvoiceID = @DocRef
	
	If @Version = 5 or @Version = 8
	Begin
		Execute sp_acc_prn_invoicedetailUOM_count @DocRef
	End
	Else
	Begin
		SELECT  Count(*)
		FROM InvoiceDetail, Items
		WHERE   InvoiceDetail.InvoiceID = @DocRef AND
			InvoiceDetail.Product_Code = Items.Product_Code
	End    
End
Else if @DocType= @BILL OR @DocType= @BILLAMENDMENT OR @DocType= @BILLCANCELLATION    
 OR @DocType= @MANUALJOURNALBILL    
Begin    
	If @Version = 5 or @Version = 8  
	Begin
		Execute sp_acc_prn_billdetailUOM_count @DocRef   
	End
	Else  
	Begin  
		 SELECT  Count(*)
		 FROM BillDetail
		 Left Join Items on BillDetail.Product_Code = Items.Product_Code
		 Left Join Billabstract on Billdetail.Billid = Billabstract.Billid
		 --BillDetail, Items  , Billabstract
		 WHERE BillDetail.BillID = @DocRef 
		  --AND  
		 --BillDetail.Product_Code *= Items.Product_Code  and
		 --Billdetail.Billid *= Billabstract.Billid
	End
End    
Else If @DocType = @PURCHASERETURN OR @DocType = @PURCHASERETURNCANCELLATION OR @DocType = @MANUALJOURNALPURCHASERETURN OR @DocType = @PURCHASERETURN_AMENDMENT    
Begin    
	DECLARE @BillID int
	SELECT Top 1 @BillID = BillAbstract.BillID FROM AdjustmentReturnDetail, BillAbstract WHERE AdjustmentReturnDetail.BillID = BillAbstract.DocumentID AND AdjustmentID = @DocRef
	
	If @Version = 5 or @Version = 8
	Begin
		Execute sp_acc_prn_StkAdjRetdetailUOM_Count @DocRef
	End
	Else
	Begin
		SELECT count(*)
		FROM AdjustmentReturnDetail
		Left Join Items on AdjustmentReturnDetail.Product_Code = Items.Product_Code
		Left Join StockAdjustmentReason on AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID
		--AdjustmentReturnDetail, Items, StockAdjustmentReason
		WHERE 	AdjustmentID = @DocRef 
		--AND AdjustmentReturnDetail.Product_Code *= Items.Product_Code AND 
		--AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID
	End    
End
Else If @DocType= @COLLECTIONS OR @DocType=@COLLECTIONCANCELLATION OR @DocType= @COLLECTIONAMENDMENT OR @DocType= @MANUALJOURNALCOLLECTIONS OR @DocType= @MANUALJOURNALOTHERRECEIPTS    
Begin    
 Set @PaymentMode=(Select PaymentMode from Collections where DocumentID=@DocRef)    
 Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)    
 If @CustomerID is not null    
 Begin 
  If @PaymentMode=0    
  Begin    
   select count(*) from     
   CollectionDetail where CollectionID=@DocRef    
  End    
  Else    
  Begin    
    select Count(*) from    
    CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID    
  End    
 End    
 Else    
 Begin    
  If @PaymentMode=0    
  Begin    
   select Count(*) from     
   CollectionDetail where CollectionID=@DocRef    
  End    
  Else    
  Begin    
    select Count(*) from    
    CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID    
  End    
 End    
End    
Else If @DocType= @DEPOSITS or @DocType=@REPOFBOUNCECHEQUE    
Begin    
  select count(*)
  from Collections where DepositID=@DocRef    
/*    
  select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate),    
  'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,    
  'Value'=DocumentValue, 'Adjusted Amount' = AdjustedAmount,Null,    
  'Doc Ref'=case when documentType=4 then cast((Select InvoiceID from InvoiceAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,  'Doc Type'=Case when DocumentType=4 then @Invoice else DocumentType end,    
  'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),    
  'Cheque Number'=Collections.ChequeNumber,    
  'Deposit date'=dbo.stripdatefromtime(Collections.DepositDate),     
  Case when DocumentType=4 then 13 else @SPECIALCASE2 end     
  from CollectionDetail,Collections where CollectionID=@DocRef and     
  Collections.DocumentID=CollectionDetail.CollectionID     
*/    
End    
Else If @DocType= @BOUNCECHEQUE    
Begin    
 Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)    
 If @CustomerID is not null    
 Begin    
  select Count(*) from CollectionDetail,Collections where     
  CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID     
 End    
 Else    
 Begin    
  select Count(*) from CollectionDetail,Collections where     
  CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID     
 End    
End    
    
Else If @DocType= @PAYMENTS or @DocType= @AUTOENTRY or @DocType= @PAYMENTCANCELLATION    
 OR @DocType = @MANUALJOURNALPAYMENTS OR @DocType= @MANUALJOURNALOTHERPAYMENTS    
 or @DocType = @PAYMENT_AMENDMENT    
Begin    
 Set @PaymentMode=(Select PaymentMode from Payments where DocumentID=@DocRef)    
 Set @VendorID=(Select VendorID from Payments where DocumentID=@DocRef)    
 If @VendorID is not Null    
 Begin    
  If @PaymentMode=0    
  Begin    
   select Count(*) from PaymentDetail where PaymentID=@DocRef    
  End    
  Else    
  Begin    
   select Count(*)
   from PaymentDetail,Payments where PaymentID=@DocRef and payments.DocumentID=PaymentDetail.PaymentID    
  End    
 End    
 Else    
 Begin    
  If @PaymentMode=0    
  Begin    
   select Count(*) from     
   PaymentDetail where PaymentID=@DocRef    
  End    
  Else    
  Begin    
   select Count(*)
   from PaymentDetail,Payments where PaymentID=@DocRef    
   and payments.DocumentID=PaymentDetail.PaymentID    
  End    
 End    
End    
Else if @DocType = @CLAIMSTOVENDOR OR @DocType = @CLAIMSSETTLEMENT OR @DocType = @CLAIMSCANCELLATION or @DocType = @MANUALJOURNAL_CLAIMS    
Begin    
	SELECT Count(*) FROM ClaimsDetail, Items
	WHERE ClaimsDetail.ClaimID = @DocRef
	AND ClaimsDetail.Product_Code = Items.Product_Code
End    
Else if @DocType = @MANUALJOURNALOLDREF    
Begin    
	Select Count(*)
	from GeneralJournal,AccountsMaster where     
	GeneralJournal.AccountID = AccountsMaster.AccountID and     
	TransactionID=@DocRef and DocumentType not in (36,37) --36 is diplay entry in manual journal form    
End    
Else IF @DocType = @ARV OR @DocType = @ARVCANCELLATION OR @DocType= @MANUALJOURNALARV Or @Doctype = @ARV_AMENDMENT    
Begin    
	select Count(*) from ARVDetail where DocumentID=@DocRef    	
End    
Else IF @DocType = @APV OR @DocType = @APVCANCELLATION OR @DocType= @MANUALJOURNALAPV Or @DocType = @APV_AMENDMENT  
Begin    
 	select Count(*) from APVDetail where DocumentID=@DocRef    
End    
Else IF @DocType = @ARVDETAIL    
Begin    
Declare @TYPE_ASSET INT
Declare @TYPE_OTHER INT
Declare @TYPE_CREDITCARD INT
Declare @TYPE_COUPON INT

Set @TYPE_ASSET = 0
Set @TYPE_OTHER = 1
Set @TYPE_CREDITCARD = 3
Set @TYPE_COUPON = 4


	If @DocRef=@TYPE_ASSET
	Begin
-- -- 		Create Table #TempDynamicTableAsset(Serial Varchar(250),Amount Decimal(18,6),Dummy1 Numeric(9,2))
-- -- 		Insert into #TempDynamicTableAsset
		Exec sp_acc_rpt_arvsubdetail @DocRef,@Info,1
-- -- 		Select count(*) from #TempDynamicTableAsset
-- -- 		Drop Table #TempDynamicTableAsset
	End
	Else If @DocRef=@TYPE_CREDITCARD
	Begin
-- -- 		Create Table #TempDynamicTableCreditCard(ContraID Varchar(15),Customer Varchar(255),
-- -- 		Number Varchar(255),Type Varchar(255),
-- -- 		InvoiceID Varchar(15),Amount Decimal(18,6),Dummy1 numeric(9,2))
-- -- 		Insert into #TempDynamicTableCreditCard
		Exec sp_acc_rpt_arvsubdetail @DocRef,@Info,1
-- -- 		Select count(*) from #TempDynamicTableCreditCard
-- -- 		Drop Table #TempDynamicTableCreditCard
	End
	Else If @DocRef=@TYPE_COUPON
	Begin
-- -- 		Create Table #TempDynamicTableCoupon(ContraID Varchar(15),
-- -- 		Customer Varchar(255),Coupon Varchar(255),Quantity Varchar(255),Rate Decimal(18,6),
-- -- 		Amount Decimal(18,6),Dummy1 numeric(9,2))
-- -- 		Insert into #TempDynamicTableCoupon
		Exec sp_acc_rpt_arvsubdetail @DocRef,@Info,1
-- -- 		Select count(*) from #TempDynamicTableCoupon
-- -- 		Drop Table #TempDynamicTableCoupon
	End
	Else
	Begin
-- -- 		Create Table #TempDynamicTable(Remark Varchar(250),Amount Decimal(18,6),Dummy1  numeric(9,2))
-- -- 		Insert into #TempDynamicTable
		Exec sp_acc_rpt_arvsubdetail @DocRef,@Info,1
-- -- 		Select count(*) from #TempDynamicTable
-- -- 		Drop Table #TempDynamicTable
	End
End    
Else IF @DocType = @APVDETAIL    
Begin    
	If @DocRef=2 
	Begin
-- -- 		Create Table #APVDynamicTableAsset(Serial Varchar(250),Amount varchar(250),Dummy1 numeric(9,2))
-- -- 		Insert into  #APVDynamicTableAsset
		Execute sp_acc_rpt_apvsubdetail @DocRef,@Info ,1   
-- -- 		Select count(*) from #APVDynamicTableAsset
-- -- 		Drop Table #APVDynamicTableAsset
	End
	Else if @DocRef=1
	Begin
-- -- 		Create Table #APVDynamicTable(Serial Varchar(250),Amount varchar(250),Dummy1 numeric(9,2))
-- -- 		Insert into  #APVDynamicTable
		Execute sp_acc_rpt_apvsubdetail @DocRef,@Info  ,1  
-- -- 		Select count(*) from #APVDynamicTable
-- -- 		Drop Table #APVDynamicTable
	End
	Else if @DocRef=0
	Begin
-- -- 		Create Table #APVDynamicTableItem(ItemName Varchar(250),Qty varchar(250),Rate Varchar(250),Amount Varchar(250),Dummy1 numeric(9,2))
-- -- 		Insert into  #APVDynamicTableItem
		Execute sp_acc_rpt_apvsubdetail @DocRef,@Info  ,1  
-- -- 		Select count(*) from #APVDynamicTableItem
-- -- 		Drop Table #APVDynamicTableItem
	End

-- --  Execute sp_acc_rpt_apvsubdetail @DocRef,@Info    
End    
Else if @DocType= @STOCKTRANSFERIN or @DocType= @STOCKTRANSFERINAMENDMENT or @DocType= @STOCKTRANSFERINCANCELLATION     
Begin    
	SELECT  Count(*)
	FROM stocktransferindetail
	Left Join Items on stocktransferindetail.Product_Code = Items.Product_Code
	--stocktransferindetail, Items
	WHERE   stocktransferindetail.DocSerial = @DocRef 
	--AND stocktransferindetail.Product_Code *= Items.Product_Code
-- --  Execute sp_acc_rpt_stocktransferindetail @DocRef    
End    
Else if @DocType= @STOCKTRANSFEROUT or @DocType=@STOCKTRANSFEROUTAMENDMENT   or @DocType=@STOCKTRANSFEROUTCELLATION       
Begin    
	SELECT  Count(*)
	FROM stocktransferoutdetail
	Left Join Items on stocktransferoutdetail.Product_Code = Items.Product_Code
	WHERE stocktransferoutdetail.DocSerial = @DocRef 
	--AND
	--stocktransferoutdetail.Product_Code *= Items.Product_Code
-- --  Execute sp_acc_rpt_stocktransferoutdetail @DocRef
End    
Else if @DocType= @DISPATCH OR @DocType= @DISPATCHAMENDMENT OR @DocType= @DISPATCHCANCELLATION    
 --OR @DocType= @MANUALJOURNALBILL    
Begin    
	If @Version = 5 or @Version = 8
	Begin
		Execute sp_acc_prn_dispatchdetailUOM_count @DocRef    
	End
	Else
	Begin
		SELECT  Count(*)
		FROM DispatchDetail
		Join Items on DispatchDetail.Product_Code = Items.Product_Code
		Left Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code
		WHERE   DispatchDetail.DispatchID = @DocRef 
		--AND DispatchDetail.Product_Code = Items.Product_Code AND
		--DispatchDetail.Batch_Code *= Batch_Products.Batch_Code
	End
-- --  Execute sp_acc_rpt_dispatchdetail @DocRef    
End    
Else if @DocType= @GRN OR @DocType= @GRNAMENDMENT OR @DocType= @GRNCANCELLATION    
Begin    
	If @Version = 2 or @Version = 3 or @Version = 6 or @Version = 9  
	Begin
		SELECT  Count(*)
		FROM	Batch_Products, Items, ItemCategories
		WHERE	Batch_Products.GRN_ID = @DocRef AND 
		Batch_Products.Product_Code = Items.Product_Code
		AND ItemCategories.CategoryID = Items.CategoryID 
		AND Batch_Products.QuantityReceived > 0
	End
	Else If @Version = 1 or @Version = 4 or @Version = 7 or @Version = 10 
	Begin
		SELECT  Count(*)
		FROM	Batch_Products, Items, ItemCategories
		WHERE	Batch_Products.GRN_ID = @DocRef AND 
		Batch_Products.Product_Code = Items.Product_Code
		AND ItemCategories.CategoryID = Items.CategoryID 
		AND Batch_Products.QuantityReceived > 0
	End
	Else If @Version = 5
	Begin
		Execute	sp_acc_prn_grnitemswholesaleUOM_count @DocRef
	End
	Else If @Version = 8
	Begin
		Execute	sp_acc_prn_grnitemsfmcgUOM_count @DocRef
	End
-- --  Execute sp_acc_rpt_grnitems @DocRef    
End    
Else if @DocType= @INTERNALCONTRA OR @DocType= @INTERNALCONTRACANCELLATION    
Begin    
	select Count(*)
	from ContraAbstract,ContraDetail     
	where ContraAbstract.ContraID = @DocRef and    
	ContraAbstract.ContraID = ContraDetail.ContraID    
End    
Else if @DocType= @INTERNALCONTRADETAIL    
Begin     
 	select @PaymentType = PaymentType from ContraDetail where ContraID = @DocRef    
 	and FromAccountID = @Info     
 	If @PaymentType = 2    
 	Begin    
 	 	select Count(*)
  		from ContraDetail Where ContraID = @DocRef and FromAccountID = @Info    
  		and PaymentType = @PaymentType      
 	End    
 	Else If @PaymentType = 3    
 	Begin    
  		select Count(*)
  		from ContraDetail Where ContraID = @DocRef and FromAccountID = @Info    
  		and PaymentType = @PaymentType      
 	End    
 	Else If @PaymentType = 4    
 	Begin    
  		Select Count(*)
  		from ContraDetail Where ContraID = @DocRef and FromAccountID = @Info    
  		and PaymentType = @PaymentType      
 	End    
 	Else If @PaymentType = 5    
 	Begin    
  		Select Count(*)
  		from ContraDetail Where ContraID = @DocRef and FromAccountID = @Info    
  		and PaymentType = @PaymentType      
 	End    
End    
Else if @DocType= @INTERNALCONTRADETAIL    
Begin    
 	select Count(*) from PaymentDetail where PaymentID=@DocRef    
End 
Else If @DocType=@ISSUE_SPARES or @DocType=@ISSUE_SPARES_CANCEL 
Begin
	Select count(*) from 
	--IssueDetail I,Items,UOM,PersonnelMaster,    
	--GeneralMaster GM,Item_Information 
	IssueDetail I
	Join Items on I.Product_Code=Items.Product_Code
	Join UOM on I.UOM=UOM.UOM
	Join Item_Information on I.Product_Specification1=Item_Information.Product_Specification1
	Left Join PersonnelMaster on I.PersonnelID =PersonnelMaster.PersonnelID 
	Left Join GeneralMaster GM on Item_Information.Color = GM.Code
	Where 
	--I.Product_Code=Items.Product_Code    
	--And I.UOM=UOM.UOM 
	--And I.Product_Specification1=Item_Information.Product_Specification1    
	--And I.PersonnelID*=PersonnelMaster.PersonnelID 
	--And Item_Information.Color*=GM.Code    
	--And 
	I.IssueID=@DocRef    
End    
Else If @DocType=@ISSUE_SPARES_RETURN
Begin
	Select Count(*) from 
	--IssueDetail I,Items,UOM,PersonnelMaster,
	--SparesReturnInfo,GeneralMaster GM,Item_Information 
	IssueDetail I
	Join Items on I.Product_Code=Items.Product_Code
	Join UOM on I.UOM=UOM.UOM
	Join Item_Information on I.Product_Specification1=Item_Information.Product_Specification1 
	Left Join PersonnelMaster on I.PersonnelID = PersonnelMaster.PersonnelID 
	Left Join GeneralMaster GM on Item_Information.Color=GM.Code
	Join SparesReturnInfo on SparesReturnInfo.SerialNo=I.SerialNo 

	

	Where 
	--I.Product_Code=Items.Product_Code
	--And I.UOM=UOM.UOM 
	--And I.Product_Specification1=Item_Information.Product_Specification1    
	--And I.PersonnelID*=PersonnelMaster.PersonnelID 
	--And Item_Information.Color*=GM.Code    
	--And SparesReturnInfo.SerialNo=I.SerialNo 
	--And 
	SparesReturnInfo.TransactionID=@DocRef
End
Else If @DocType=@SERVICE_INVOICE or @DocType=@SERVICE_INVOICE_CANCEL    
Begin    
	Select Count(*)
	from 
	--ServiceInvoiceDetail SID,Item_Information,Items,GeneralMaster GM    
	ServiceInvoiceDetail SID
	Join Items on SID.Product_code=Items.Product_Code
	Join Item_Information on SID.Product_Code=Item_Information.Product_code and  SID.Product_Specification1=Item_Information.Product_Specification1 
	Left Join GeneralMaster GM on Item_Information.Color=GM.Code 

	Where 
	SID.Type In (2,3) 
	--And SID.Product_code=Items.Product_Code    
	--And SID.Product_Code=Item_Information.Product_code     
	--And SID.Product_Specification1=Item_Information.Product_Specification1    
	--And Item_Information.Color*=GM.Code 
	And SID.ServiceInvoiceID=@DocRef    
End



