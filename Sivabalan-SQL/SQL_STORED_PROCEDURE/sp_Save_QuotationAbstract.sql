Create PROCEDURE sp_Save_QuotationAbstract(@QuotationID INT, @ValidFromDate DateTime,      
@ValidToDate DateTime, @AllowInvoiceScheme INT, @QuotationType INT, @Active INT,@QuotationSubType int,@QuotationLevel int,
@UOMConv int,@SplTax int = 0, @ModifiedUser nvarchar(50) = '')      
AS      
Begin
	UPDATE QuotationAbstract SET ValidFromDate = @ValidFromDate,     
	ValidToDate = DateAdd(ss,59,DateAdd(mi,59,DateAdd(hh,23,dbo.StripDateFromTime(@ValidToDate)))),      
	AllowInvoiceScheme = @AllowInvoiceScheme, QuotationType = @QuotationType, Active = @Active,       
	LastModifiedDate = GetDate(),QuotationSubType=@QuotationSubType,QuotationLevel=@QuotationLevel,
	UOMConversion=@UOMConv ,SpecialTax=  @SplTax, ModifiedUser = @ModifiedUser 
	WHERE QuotationID = @QuotationID

	SELECT @QuotationID, DocumentID FROM QuotationAbstract WHERE QuotationID = @QuotationID 
End
