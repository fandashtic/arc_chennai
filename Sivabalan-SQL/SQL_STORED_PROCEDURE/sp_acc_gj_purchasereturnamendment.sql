CREATE procedure sp_acc_gj_purchasereturnamendment(@Adjustmentid integer,@BackDate DATETIME=Null)
as
declare @nadjustmentid integer,@dadjustmentdate datetime,@nvalue decimal(18,6),@accountid integer
declare @documentid integer,@nvendorid nvarchar(15),@purchase integer,@ndoctype integer
declare @purchasereturn integer 
declare @uniqueid integer
declare @purchasetax integer
declare @totalvalue decimal(18,6)
declare @taxvalue decimal(18,6) 
declare @amendedid int
declare @amendeddate datetime
declare @amendedvalue decimal(18,6)
declare @amendedtotalvalue decimal(18,6)
declare @amendedtotaltax decimal(18,6)
declare @amendedvendor nvarchar(20)
declare @amendedvendoraccount int
Declare @amendedILevelTaxValue decimal(18,6)
Declare @ILevelTaxValue decimal(18,6)
declare @AMENDMENTTYPE INT

set @purchasereturn =31       /* Constant to store the Purchase return AccountID*/
set @ndoctype=11        /* Variable to store the Document Type*/
set @accountid=0       /* Constant to store the Vendors AccountID*/  
set @purchasetax =2
set @AMENDMENTTYPE = 73

Declare @Vat_Exists Integer
Declare @VAT_Receivable Integer
Declare @nVatTaxamount decimal(18,6)
Declare @nAmendedVatTaxamount decimal(18,6)
Set @VAT_Receivable = 115  /* Constant to store the VAT Receivable (Input Tax Credit) AccountID*/     

Create Table #TempBackdatedpurchasereturnamendment(AccountID Int) --for backdated operation

--GST_Changes starts here
Declare @GSTEnable int,
		@GSTCount int , 
		@Rowid int, 
		@GST_receivable int, 
		@GSTaxComponent int ,
		@nGSTaxAmt decimal(18,6),
		@comp_tax	decimal(18,6),
		@adj_tax	decimal(18,6),
		@vat_flag	int

Select @GSTEnable = isnull(flag,0) 
From tbl_merp_configabstract(nolock)
Where screencode = 'GSTaxEnabled'  

Create Table #GSTaxCalc  --For GS Tax Calculation Amendment
(	id int identity(1,1), 
	adjustmentid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	vat_flag	int
)

Create Table #GSTaxCalcAmend  --For GS Tax Calculation Amended
(	id int identity(1,1), 
	adjustmentid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	vat_flag	int
)
--GST_Changes ends here 

Set @Vat_Exists = 0 
If dbo.columnexists('AdjustmentReturnabstract','VATTaxAmount') = 1
Begin
	Set @Vat_Exists = 1
end
If @Vat_Exists  = 1
Begin
	select @nadjustmentid = [AdjustmentID],@dadjustmentdate = [AdjustmentDate],@nvalue = ISNULL([Value],0),
	@nvendorid=ISNULL([VendorID],0),@totalvalue = isnull(Total_Value,0), 
	@amendedid = isnull(AdjustmentIDRef,0) ,
	@nVatTaxamount = isnull(VATTaxAmount,0)
	from AdjustmentReturnabstract 
	where [AdjustmentID]=@Adjustmentid
	
	select @amendeddate = [AdjustmentDate],@amendedvalue = ISNULL([Value],0),
	@amendedtotalvalue = isnull(Total_Value,0),@amendedvendor = VendorID,
	@nAmendedVatTaxamount = isnull(VATTaxAmount,0)
	from AdjustmentReturnabstract 
	where [AdjustmentID]=@amendedid
End
Else
Begin
	select @nadjustmentid = [AdjustmentID],@dadjustmentdate = [AdjustmentDate],@nvalue = ISNULL([Value],0),
	@nvendorid=ISNULL([VendorID],0),@totalvalue = isnull(Total_Value,0), 
	@amendedid = isnull(AdjustmentIDRef,0) from AdjustmentReturnabstract 
	where [AdjustmentID]=@Adjustmentid
	
	select @amendeddate = [AdjustmentDate],@amendedvalue = ISNULL([Value],0),
	@amendedtotalvalue = isnull(Total_Value,0),@amendedvendor = VendorID
	from AdjustmentReturnabstract 
	where [AdjustmentID]=@amendedid
End

--GST_Changes starts here
--GST Enabled 
if @GSTEnable = 1 
begin
	--Amendment Component wise tax
	insert into #gstaxcalc 
	(adjustmentid	, tax_component_code	,	tax_value	  ,	vat_flag)
	select distinct
	pr.adjustmentid , pr.tax_component_code ,	sum(tax_value),	0		
	from  PRTaxComponents	pr(nolock)
	where pr.adjustmentid = @Adjustmentid
	group by pr.adjustmentid,pr.tax_component_code
	
	select  @comp_tax	=  isnull(sum(tax_value),0)
	from	#gstaxcalc (nolock)
	where	adjustmentid = @Adjustmentid
	group by  adjustmentid

	select  @adj_tax	=	isnull(sum(vattaxamount),0)
	from	AdjustmentReturnabstract (nolock)
	where	adjustmentid = @Adjustmentid
	group by  adjustmentid
	
	--Tax difference as SGST Input
	if (Round((isnull(@adj_tax,0) - isnull(@comp_tax,0)),2) <> 0)
	begin
		insert into #gstaxcalc 
		(adjustmentid	, tax_component_code	,	tax_value			 ,	vat_flag)
		select
		@Adjustmentid	, 0			,	(isnull(@adj_tax,0) - isnull(@comp_tax,0)) , 1	    
	end	 

	--Amended Component wise tax
	insert into #gstaxcalcamend 
	(adjustmentid	, tax_component_code	,	tax_value	  ,	vat_flag)
	select distinct
	pr.adjustmentid , pr.tax_component_code ,	sum(tax_value),	0		
	from  PRTaxComponents	pr(nolock)
	where pr.adjustmentid = @amendedid
	group by pr.adjustmentid,pr.tax_component_code
	
	select  @comp_tax	=  isnull(sum(tax_value),0)
	from	#gstaxcalcamend (nolock)
	where	adjustmentid = @amendedid
	group by  adjustmentid

	select  @adj_tax	=	isnull(sum(vattaxamount),0)
	from	AdjustmentReturnabstract (nolock)
	where	adjustmentid = @amendedid
	group by  adjustmentid
	
	--Tax difference as SGST Input
	if (Round((isnull(@adj_tax,0) - isnull(@comp_tax,0)),2) <> 0)
	begin
		insert into #gstaxcalcamend 
		(adjustmentid	, tax_component_code	,	tax_value			 ,	vat_flag)
		select
		@amendedid	, 0			,	(isnull(@adj_tax,0) - isnull(@comp_tax,0)) , 1	    
	end	 		
end
--GST_Changes ends here

select @accountid=ISNULL([AccountID],0)
from [Vendors]
where [VendorID]=@nvendorid  

select @amendedvendoraccount =ISNULL([AccountID],0)
from [Vendors]
where [VendorID]=@amendedvendor  

begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
commit tran

begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
commit tran


If @Vat_Exists  = 1
Begin
	set @amendedtotaltax = @amendedtotalvalue - @amendedvalue - @nAmendedVatTaxamount
End
Else
Begin
	set @amendedtotaltax = @amendedtotalvalue - @amendedvalue
End
If @amendedvalue <> 0 
Begin

	/*LOGIC: If any SKU is selected FLST / FMRP tax type then FA posting is changed as
	Purchase Return Account : Total Amount + FLST / FMRP Tax Value
	VAT / Tax Account: TaxAmount - FLST / FMRP Tax Value
	*/
	if (@GSTEnable <> 1 ) --GST_Changes
	begin
		Select @amendedILevelTaxValue= sum(isnull(TaxAmount,0)) from AdjustmentReturnDetail join Batch_Products 
		ON AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_code
		where [AdjustmentID]=@amendedid and Batch_Products.TaxType in(3,4)
		
		select @amendedILevelTaxValue = Round(@amendedILevelTaxValue,2)
		Select @amendedvalue = isnull(@amendedvalue,0)+ isnull(@amendedILevelTaxValue,0)
	end
	else 
		Select @amendedILevelTaxValue= 0 --GST_Changes

	if @amendedvalue <> 0
	begin
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@purchasereturn,@amendeddate,@amendedvalue,0,@amendedid,@AMENDMENTTYPE,'Purchase Return Amended',@uniqueid)
		Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@purchasereturn)
	end

	if Round(isnull(@amendedtotaltax,0),2) <> 0 And Round((isnull(@amendedtotaltax,0) - isnull(@amendedILevelTaxValue,0)),2) <> 0  
	begin
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@purchasetax,@amendeddate,isnull(@amendedtotaltax,0)-isnull(@amendedILevelTaxValue,0),0,@amendedid,@AMENDMENTTYPE,'Purchase Return Amended',@uniqueid)  
		Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@purchasetax)
	end
	
	--GST_Changes starts
	if @GSTEnable = 1 
	begin		
		select @gstcount = max(id) from #GSTaxCalcAmend
		if (@gstcount > 0)
		begin
			select @rowid = 1
			while ( @rowid <= @gstcount)		
			begin
				select	@GSTaxComponent = Tax_Component_Code,
						@nGSTaxAmt		= Tax_Value, 
						@vat_flag		= vat_flag
				from	#GSTaxCalcAmend
				where	id = @rowid
				
				if @nGSTaxAmt <> 0    
				begin
					if(@vat_flag = 0)--Entry for GS Tax Accounts
					begin
						select  @GST_receivable	  = InputAccID 
						from	TaxComponentDetail(nolock) 
						where	TaxComponent_Code = @GSTaxComponent

						if ((isnull(@GST_receivable,0)>0) and (Round(isnull(@nGSTaxAmt,0)-isnull(@amendedILevelTaxValue,0),2) <> 0))
						begin
							insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
							Values(@documentid,@GST_receivable,@amendeddate,isnull(@nGSTaxAmt,0)-isnull(@amendedILevelTaxValue,0),0,@amendedid,@AMENDMENTTYPE,'Purchase Return Amended',@uniqueid)  
							Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@GST_receivable)
						end
					end
					else --Entry for SGST Input
					begin
						if (( select isnull(flag,0)
							  from tbl_merp_configabstract(nolock)
							  where screencode = 'UTGST' ) = 1)
						begin
							select	@gst_receivable	= accountid
							from	accountsmaster (nolock)
							where	accountname		= 'UTGST Input'
						end
						else
						begin
							select	@gst_receivable	= accountid
							from	accountsmaster (nolock)
							where	accountname		= 'SGST Input'
						end	

						if ((isnull(@GST_receivable,0)>0) and (Round(isnull(@nGSTaxAmt,0)-isnull(@amendedILevelTaxValue,0),2) <> 0))
						begin
							insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
							Values(@documentid,@GST_receivable,@amendeddate,isnull(@nGSTaxAmt,0)-isnull(@amendedILevelTaxValue,0),0,@amendedid,@AMENDMENTTYPE,'VAT Purchase Return Amended',@uniqueid)  
							Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@GST_receivable)
						end
					end
				end
				select @rowid = @rowid+1
			end 
		end 
	 end
	else --GST_Changes ends
	If @Vat_Exists = 1
	Begin
 		if Round(isnull(@nAmendedVatTaxamount,0),2) <> 0  And Round((isnull(@nAmendedVatTaxamount,0)- isnull(@amendedILevelTaxValue,0)),2) <> 0  
 		begin  
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@VAT_Receivable,@amendeddate,isnull(@nAmendedVatTaxamount,0)-isnull(@amendedILevelTaxValue,0),0,@amendedid,@AMENDMENTTYPE,'Purchase Return Amended',@uniqueid)  
			Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@VAT_Receivable)
		end
	End

	if @amendedtotalvalue <> 0
	begin
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@amendedvendoraccount,@amendeddate,0,@amendedtotalvalue,@amendedid,@AMENDMENTTYPE,'Purchase Return Amended',@uniqueid)  
		Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@accountid)
	end
End

if @accountid <> 0
begin
	begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	commit tran

	begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
	select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	commit tran

	If @Vat_Exists  = 1
	Begin
		set @taxvalue = @totalvalue - @nvalue - @nVatTaxamount
	End
	Else
	Begin
		set @taxvalue = @totalvalue - @nvalue
	End
	
	if (@GSTEnable <> 1 ) --GST_Changes
	begin
		Select @ILevelTaxValue= sum(isnull(TaxAmount,0)) from AdjustmentReturnDetail join Batch_Products 
		ON AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_code
		where [AdjustmentID]=@nadjustmentid and Batch_Products.TaxType in(3,4)

		select @ILevelTaxValue = Round(@ILevelTaxValue,2)
		Select @nvalue = isnull(@nvalue,0)+ isnull(@ILevelTaxValue,0)
	end
	else
		Select @ILevelTaxValue= 0 --GST_Changes

	If @totalvalue <> 0
	Begin
		if @totalvalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@accountid,@dadjustmentdate,@totalvalue,0,@nadjustmentid,@AMENDMENTTYPE,'Purchase Return Amendment',@uniqueid)  
			Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@accountid)
		end

		if @nvalue <> 0
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@purchasereturn,@dadjustmentdate,0,@nvalue,@nadjustmentid,@AMENDMENTTYPE,'Purchase Return Amendment',@uniqueid)
			Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@purchasereturn)
		end

		if Round(isnull(@taxvalue,0),2) <> 0 And Round((isnull(@taxvalue,0)- isnull(@ILevelTaxValue,0)),2) <> 0  
		begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
			Values(@documentid,@purchasetax,@dadjustmentdate,0,isnull(@taxvalue,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@AMENDMENTTYPE,'Purchase Return Amendment',@uniqueid)  
			Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@purchasetax)
		end
		--GST_Changes starts
		if @GSTEnable = 1 
		begin		
			select @gstcount = max(id) from #GSTaxCalc
			if (@gstcount > 0)
			begin
				select @rowid = 1
				while ( @rowid <= @gstcount)		
				begin
					select	@GSTaxComponent = Tax_Component_Code,
							@nGSTaxAmt		= Tax_Value , 
							@vat_flag		= vat_flag
					from	#GSTaxCalc
					where	id = @rowid
					
					if @nGSTaxAmt <> 0    
					begin
						if(@vat_flag = 0)--Entry for GS Tax Accounts
						begin
							select  @GST_receivable	  = InputAccID 
							from	TaxComponentDetail(nolock) 
							where	TaxComponent_Code = @GSTaxComponent

							if ((isnull(@GST_receivable,0)>0) and (Round(isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),2) <> 0))
							begin
								insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
								Values(@documentid,@GST_receivable,@dadjustmentdate,0,isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@AMENDMENTTYPE,'Purchase Return Amendment',@uniqueid)  
								Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@GST_receivable)
							end
						end
						else
						begin --Entry for SGST Input
							if (( select isnull(flag,0)
								  from tbl_merp_configabstract(nolock)
								  where screencode = 'UTGST' ) = 1)
							begin
								select	@gst_receivable	= accountid
								from	accountsmaster (nolock)
								where	accountname		= 'UTGST Input'
							end
							else
							begin
								select	@gst_receivable	= accountid
								from	accountsmaster (nolock)
								where	accountname		= 'SGST Input'
							end	
							
							if ((isnull(@GST_receivable,0)>0) and (Round(isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),2) <> 0))
							begin
								insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
								Values(@documentid,@GST_receivable,@dadjustmentdate,0,isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@AMENDMENTTYPE,'VAT Purchase Return Amendment',@uniqueid)  
								Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@GST_receivable)
							end
						end
					end
					select @rowid = @rowid+1
				end 
			end 			
		 end
		else --GST_Changes ends
		If @Vat_Exists = 1
		Begin
 			if Round(isnull(@nVatTaxamount,0),2) <> 0  And Round((isnull(@nVatTaxamount,0) - isnull(@ILevelTaxValue,0)),2) <> 0  
 			begin  
				insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
				Values(@documentid,@VAT_Receivable,@dadjustmentdate,0,isnull(@nVatTaxamount,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@AMENDMENTTYPE,'Purchase Return Amendment',@uniqueid)  
				Insert Into #TempBackdatedpurchasereturnamendment(AccountID) Values(@VAT_Receivable)
			end
		End
	End
end
If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedpurchasereturnamendment
	OPEN scantempbackdatedaccounts
	FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
	WHILE @@FETCH_STATUS =0
	Begin
		Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
		FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
	End
	CLOSE scantempbackdatedaccounts
	DEALLOCATE scantempbackdatedaccounts
End
Drop Table #TempBackdatedpurchasereturnamendment
Drop Table #GSTaxCalc --GST_Changes 
Drop Table #GSTaxCalcAmend --GST_Changes 
