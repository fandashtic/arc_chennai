CREATE procedure sp_acc_updatecontradetail(@contraid int,@fromaccountid int,
@toaccountid int,@amounttransferred decimal(18,6),@paymenttype int,@additionalinfo_number nvarchar(50) = N'',
@additionalinfo_date datetime = NULL,@additionalinfo_bankcode nvarchar(20) = N'',
@additionalinfo_branchcode nvarchar(20) = N'',@additionalinfo_amount decimal(18,6)= 0,
@additionalinfo_qty int = 0,@additionalinfo_value decimal(18,6)=0,
@additionalinfo_party int = 0,@documentreference int =0,@documenttype int =0,@originalid nvarchar(20) = N'',
@denominations nvarchar(2000) = N'',@additionalinfo_type nvarchar(50),@additionalinfo_fromserialno int =0,
@additionalinfo_toserialno int =0,@additionalinfo_customer nvarchar(128) = N'',@additionalinfo_collectionid int = 0,
@additionalinfo_servicecharge decimal(18,6)= 0)
as

Insert ContraDetail(ContraID,
		    FromAccountID,
		    ToAccountID,
                    AmountTransfer,
                    PaymentType,
                    AdditionalInfo_Number,   	 	
		    AdditionalInfo_Date,
                    AdditionalInfo_BankCode,
                    AdditionalInfo_BranchCode,
                    AdditionalInfo_Amount,
                    AdditionalInfo_Qty,
                    AdditionalInfo_Value,
                    AdditionalInfo_Party,
		    AdditionalInfo_Type,	
		    AdditionalInfo_FromSerialNo,
		    AdditionalInfo_ToSerialNo,
                    DocumentReference,
		    DocumentType,
		    OriginalID,
                    Denominations,
		    AdditionalInfo_Customer,
		    AdditionalInfo_CollectionID,
		    AdditionalInfo_ServiceCharge)
             Values(@contraid,
		    @fromaccountid,
                    @toaccountid,
		    @amounttransferred,
                    @paymenttype,
                    @additionalinfo_number,
                    @additionalinfo_date,
		    @additionalinfo_bankcode,
		    @additionalinfo_branchcode,
		    @additionalinfo_amount,
		    @additionalinfo_qty,
		    @additionalinfo_value,
		    @additionalinfo_party,		
		    @additionalinfo_type,
		    @additionalinfo_fromserialno,
                    @additionalinfo_toserialno,
		    @documentreference,
		    @documenttype,
                    @originalid,
                    @denominations,
		    @additionalinfo_customer,
		    @additionalinfo_collectionid,
		    @additionalinfo_servicecharge)









