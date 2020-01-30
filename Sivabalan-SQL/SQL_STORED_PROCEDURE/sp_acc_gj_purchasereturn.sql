CREATE procedure sp_acc_gj_purchasereturn(@Adjustmentid integer,@BackDate datetime=Null)
as
declare @nadjustmentid integer,@dadjustmentdate datetime,@nvalue decimal(18,6),@accountid integer  
declare @documentid integer,@nvendorid nvarchar(15),@purchase integer,@ndoctype integer  
declare @purchasereturn integer   
declare @uniqueid integer  
declare @purchasetax integer  
declare @totalvalue decimal(18,6)  
declare @taxvalue decimal(18,6)   
  
set @purchasereturn =31  /* Constant to store the Purchase return AccountID*/  
set @ndoctype=11        /* Variable to store the Document Type*/  
set @accountid=0       /* Constant to store the Vendors AccountID*/    
set @purchasetax =2  
  
Declare @Vat_Exists Integer  
Declare @VAT_Receivable Integer  
Declare @nVatTaxamount decimal(18,6)  
Declare @ILevelTaxValue decimal(18,6)
Set @VAT_Receivable = 115  /* Constant to store the VAT Receivable (Input Tax Credit) AccountID*/       
  
Create Table #TempBackdatedpurchasereturn(AccountID Int) --for backdated operation  

--GST_Changes starts here
declare @GSTEnable int,
		@GSTCount int , 
		@Rowid int, 
		@GST_receivable int, 
		@GSTaxComponent int ,
		@nGSTaxAmt decimal(18,6),
		@comp_tax	decimal(18,6),
		@adj_tax	decimal(18,6),
		@vat_flag	int

select @GSTEnable = isnull(flag,0) 
from tbl_merp_configabstract(nolock)
where screencode = 'GSTaxEnabled'  

create table #gstaxcalc  --for gs tax calculation
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
	select @nadjustmentid = [AdjustmentID],@dadjustmentdate = [AdjustmentDate],  
	@nvalue = ISNULL([Value],0),@nvendorid=ISNULL([VendorID],0),  
	@totalvalue = isnull(Total_Value,0) ,  
	@nVatTaxamount = isnull(VATTaxAmount,0)  
	from AdjustmentReturnabstract   
	where [AdjustmentID]=@Adjustmentid  
End  
Else  
Begin  
	select @nadjustmentid = [AdjustmentID],@dadjustmentdate = [AdjustmentDate],  
	@nvalue = ISNULL([Value],0),@nvendorid=ISNULL([VendorID],0),  
	@totalvalue = isnull(Total_Value,0)  
	from AdjustmentReturnabstract   
	where [AdjustmentID]=@Adjustmentid  
End  
select @accountid=ISNULL([AccountID],0)  
from [Vendors]  
where [VendorID]=@nvendorid    

--GST_Changes starts here
--GST Enabled 
if @GSTEnable = 1 
begin
	--Component wise tax
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
		@Adjustmentid	, 0	,	(isnull(@adj_tax,0) - isnull(@comp_tax,0)) , 1	    
	end	 	
end
--GST_Changes ends here
  
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
	If @totalvalue <> 0   
	Begin  
		if @totalvalue <> 0  
		begin  
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
			Values(@documentid,@accountid,@dadjustmentdate,@totalvalue,0,@nadjustmentid,@ndoctype,'Purchase Return',@uniqueid)    
			Insert Into #TempBackdatedpurchasereturn(AccountID) Values(@accountid)  
		end  

		/*LOGIC: If any SKU is selected FLST / FMRP tax type then FA posting is changed as
		Purchase Return Account : Total Amount + FLST / FMRP Tax Value
		VAT / Tax Account: TaxAmount - FLST / FMRP Tax Value
		 */
		if (@GSTEnable <> 1 ) --GST_Changes
		begin
			Select @ILevelTaxValue= sum(isnull(TaxAmount,0)) from AdjustmentReturnDetail join Batch_Products 
			ON AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_code
			where [AdjustmentID]=@Adjustmentid and Batch_Products.TaxType in(3,4)

			select @ILevelTaxValue = Round(@ILevelTaxValue,2)
			Select @nvalue = isnull(@nvalue,0)+isnull(@ILevelTaxValue,0)
		end
		else 
			Select @ILevelTaxValue= 0 --GST_Changes
		
		if isnull(@nvalue,0) <> 0  
		begin  
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
			Values(@documentid,@purchasereturn,@dadjustmentdate,0,@nvalue,@nadjustmentid,@ndoctype,'Purchase Return',@uniqueid)  
			Insert Into #TempBackdatedpurchasereturn(AccountID) Values(@purchasereturn)  
		end  
		
		if Round(isnull(@taxvalue,0),2) <> 0 And Round((isnull(@taxvalue,0)- isnull(@ILevelTaxValue,0)),2) <> 0  
		begin  
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
			Values(@documentid,@purchasetax,@dadjustmentdate,0,isnull(@taxvalue,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@ndoctype,'Purchase Return',@uniqueid)    
			Insert Into #TempBackdatedpurchasereturn(AccountID) Values(@purchasetax)  
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
							@nGSTaxAmt		= Tax_Value, 
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
								Values(@documentid,@GST_receivable,@dadjustmentdate,0,isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@ndoctype,'Purchase Return',@uniqueid)    
								Insert Into #TempBackdatedpurchasereturn(AccountID) Values(@GST_receivable)  
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
								
							if ((isnull(@GST_receivable,0)>0) and (Round(isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),2)<> 0))
							begin							 
								insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
								Values(@documentid,@GST_receivable,@dadjustmentdate,0,isnull(@nGSTaxAmt,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@ndoctype,'VAT Purchase Return',@uniqueid)    
								Insert Into #TempBackdatedpurchasereturn(AccountID) Values(@GST_receivable)  							
							end
						end
					end
					select @rowid = @rowid+1
				end 
			end 	
		 end
		else   --GST_Changes ends
		If @Vat_Exists = 1  
		Begin  
			if Round(isnull(@nVatTaxamount,0),2) <> 0  And Round((isnull(@nVatTaxamount,0)- isnull(@ILevelTaxValue,0)),2) <> 0  
			begin    
				insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
				Values(@documentid,@VAT_Receivable,@dadjustmentdate,0,isnull(@nVatTaxamount,0)-isnull(@ILevelTaxValue,0),@nadjustmentid,@ndoctype,'Purchase Return',@uniqueid)    
				Insert Into #TempBackdatedpurchasereturn(AccountID) Values(@VAT_Receivable)  
			end  
		END
	end  
End  
  
If @BackDate Is Not Null    
Begin  
	Declare @TempAccountID Int  
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR  
	Select AccountID From #TempBackdatedpurchasereturn  
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
Drop Table #TempBackdatedpurchasereturn  
Drop Table #GSTaxCalc --GST_Changes 
