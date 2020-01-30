CREATE procedure sp_acc_gj_billgrn1(@billid integer,@BackDate DATETIME=Null)
as
declare @nbillid integer,@dbilldate datetime,@nvalue decimal(18,6) ,@ntaxamount decimal(18,6)
declare @accountid integer,@groupid integer,@parentid integer
declare @documentid integer,@nvendorid nvarchar(15),@purchase integer,@purchasetax integer,@ntotalamt decimal(18,6),@ndoctype integer
declare @uniqueid integer,@grnid integer
declare @productcode integer,@count integer,@qtyrejected decimal(18,6)
declare @taxsuffered decimal(18,6),@discount decimal(18,6)
declare @product_code integer,@purchaseprice decimal(18,6)
declare @netamount decimal(18,6),@taxamount decimal(18,6),@discountcomputed decimal(18,6)
declare @discountoption integer,@overalldiscount decimal(18,6),@overalldiscountvalue decimal(18,6)

declare @acceptedvalue decimal(18,6)
declare @netvalue decimal(18,6)


declare @totalpurchase decimal(18,6)
declare @totalamount decimal(18,6)
declare @totaltaxamount decimal(18,6)
declare @rejectionvalue decimal(18,6)
declare @totalrejectionvalue decimal(18,6)

declare @REJECTIONTYPE integer
SET @REJECTIONTYPE =50

set @purchase =6	/* Constant to store the Purchase AccountID*/	
set @purchasetax =2	/* Constant to store the PurchaseTax AccountID*/	
set @ndoctype=8         /* Constant to store the Document Type*/	
set @accountid=0        /* variable to store the Vendor's AccountID*/	           
set @ntotalamt=0        /* variable to store the Summedup Value of [Value + TaxAmount]*/	

execute sp_acc_gj_grnbill @billid,@BackDate

Create Table #TempBackdatedbillgrn1(AccountID Int) --for backdated operation
                                   
select @nbillid = [BillID],@dbilldate = [BillDate],@nvalue = ISNULL(Value,0),
@ntaxamount = ISNULL([TaxAmount],0),@nvendorid=ISNULL([VendorID],0),@grnid = GRNID,
@discountoption = isnull(DiscountOption,0),@overalldiscount = isnull(Discount,0)
from BillAbstract where [BillID]=@billid 


select @acceptedvalue = (((Quantity * PurchasePrice)* discount) /100 )
from billdetail where billID =@billid


set @netamount =0
set @discountcomputed =0
set @taxamount=0
set @totaltaxamount =0
set @totalpurchase =0 
set @rejectionvalue =0
set @totalrejectionvalue =0


/*
declare scangrndetail cursor keyset for
select Product_Code,isnull(QuantityRejected,0) from GRNDetail 
where [GRNID]= @grnid and isnull([QuantityRejected],0)<>0 
open scangrndetail
fetch from scangrndetail into @productcode,@qtyrejected
while @@fetch_status =0
begin
	set @product_code =0
	select @product_code =isnull(Product_Code,0),@purchaseprice=[PurchasePrice],
	@taxsuffered= isnull(TaxSuffered,0),@discount=isnull(Discount,0)
	from BillDetail where [BillID]= @billid and [Product_Code]=@productcode 
	if @product_code > 0 
	begin
		set @netamount = @qtyrejected * @purchaseprice 								
		set @discountcomputed = (@netamount * @discount) /100
		set @netamount = @netamount - @discountcomputed 
		
		--set @netamount= @netamount + @taxamount
		if @discountoption =1
		begin
			set @overalldiscountvalue= @netamount * @overalldiscount /100
			set @netamount = @netamount - @overalldiscount
		end
		else if @discountoption =2 
		begin
			set @overalldiscountvalue= @netamount * @overalldiscount /@acceptedvalue + @netamount
			set @netamount = @netamount - @overalldiscount
		end
		set @totalpurchase = @totalpurchase + @netamount
		set @taxamount = (@netamount * @taxsuffered) /100
		set @totaltaxamount = @totaltaxamount + @taxamount
		set @rejectionvalue = @netamount + @taxamount
		set @totalrejectionvalue= @totalrejectionvalue + @rejectionvalue
		set @netamount = @netamount + @taxamount		
	end

fetch next from scangrndetail into @productcode,@qtyrejected
end

close scangrndetail
deallocate scandetail
*/

set @ntotalamt=@nvalue + @ntaxamount
select @accountid=ISNULL([AccountID],0)
from [Vendors]
where [VendorID]=@nvendorid  

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

--set @nvalue = @nvalue + @totalpurchase
--set @ntaxamount = @ntaxamount + @totaltaxamount
--set @ntotalamt = @ntotalamt + @netamount

 if @nvalue <> 0
 begin
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	 Values(@documentid,@purchase,@dbilldate,@nvalue,0,@nbillid,@ndoctype,'Bill',@uniqueid,getdate())  
	 Insert Into #TempBackdatedbillgrn1(AccountID) Values(@purchase) 	
 end
 if @ntaxamount <> 0
 begin
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	 Values(@documentid,@purchasetax,@dbilldate,@ntaxamount,0,@nbillid,@ndoctype,'Bill',@uniqueid,getdate())  
	 Insert Into #TempBackdatedbillgrn1(AccountID) Values(@purchasetax)
 end
 
 if @ntotalamt <> 0
 begin 
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	 Values(@documentid,@accountid,@dbilldate,0,@ntotalamt,@nbillid,@ndoctype,'Bill',@uniqueid,getdate())
	 Insert Into #TempBackdatedbillgrn1(AccountID) Values(@accountid)
 end

/*
 if @totalrejectionvalue <> 0
 begin
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	 Values(@documentid,@accountid,@dbilldate,@totalrejectionvalue,0,@nbillid,@REJECTIONTYPE,'Rejection',@uniqueid,getdate()) 
	
	 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	 Values(@documentid,@purchase,@dbilldate,0,@totalrejectionvalue,@nbillid,@REJECTIONTYPE,'Rejection',@uniqueid,getdate()) 
 end
*/
end

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedbillgrn1
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
Drop Table #TempBackdatedbillgrn1












