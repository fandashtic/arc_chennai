CREATE PROCEDURE sp_adjust_opening_for_cancel_invoice(@InvoiceId int, @InvoiceDate datetime, @IsReturn int = 0, @IsVan int = 0)
AS
DECLARE @Batch_Code  int
DECLARE @Quantity Decimal(18,6)
DECLARE @PurchasePrice Decimal(18,6)
DECLARE @Product_Code nvarchar(30)
DECLARE @FREE Decimal(18,6)
DECLARE @DAMAGE Decimal(18,6)
DECLARE @DispatchDate datetime
DECLARE @DispatchID int

IF ((Select Status From InvoiceAbstract Where InvoiceID = @InvoiceId) & 1) <> 0
BEGIN
	Select @DispatchID = DispatchID, @DispatchDate = dbo.StripDateFromTime(DispatchDate) 
	From DispatchAbstract Where InvoiceID = @InvoiceId
	exec sp_adjust_opening_for_cancel_dispatch @DispatchID, @DispatchDate
END
ELSE
BEGIN
	DECLARE GetReturnedInvoice CURSOR STATIC FOR
	select Product_Code, Batch_Code, Quantity, PurchasePrice from InvoiceDetail where InvoiceId = @InvoiceId
	OPEN GetReturnedInvoice
	
	FETCH FROM GetReturnedInvoice INTO  @Product_Code, @Batch_Code , @Quantity, @PurchasePrice
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @IsVan = 0
			Select @FREE = ISNULL(Free, 0), @DAMAGE = IsNull(Damage,0) From Batch_Products Where Batch_Code = @Batch_Code
		ELSE
			Select @FREE = ISNULL(Free, 0), @DAMAGE = IsNull(Damage,0) From VanStatementDetail, Batch_Products Where [ID] = @Batch_Code And VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
		IF @IsReturn = 1 
		BEGIN
			SET @Quantity = 0 - @Quantity
			SET @PurchasePrice = 0 - @PurchasePrice
		END
		exec sp_update_opening_stock @Product_Code, @InvoiceDate, @Quantity, @FREE, 0, @DAMAGE, @PurchasePrice
		FETCH NEXT FROM GetReturnedInvoice INTO @Product_Code, @Batch_Code , @Quantity, @PurchasePrice
	END
	CLOSE GetReturnedInvoice
	DEALLOCATE GetReturnedInvoice
END

