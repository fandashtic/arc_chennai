CREATE PROCEDURE sp_update_pending(@PRODUCT_CODE nvarchar(15), 
			       @RequiredQuantity Decimal(18,6),
			       @PONUMBERS NVARCHAR(255)	)
AS
declare @string nvarchar(255) declare @current_PO_number int declare @pos int
declare @start int  declare @Quantity Decimal(18,6)

set @start = 1
select @pos = charindex ( ',' , @PONUMBERS , @start)
while  @pos <> 0
begin
--storing the current po number obtained after splitting and casting --
 	select @current_PO_number = cast(substring(@PONUMBERS, @start, (@pos - @start)) as int)
--cursor code --
	DECLARE UpdateQuantity CURSOR KEYSET FOR
	SELECT pending FROM PODETAIL WHERE PRODUCT_CODE = @PRODUCT_CODE AND PONumber = @current_PO_number
	open UpdateQuantity
	FETCH FROM UpdateQuantity INTO @Quantity
	CLOSE UpdateQuantity
	DEALLOCATE UpdateQuantity
	IF @@FETCH_STATUS = 0
	BEGIN
	    IF @Quantity >= @RequiredQuantity
	    BEGIN
	        UPDATE PODetail set Pending = Pending - @RequiredQuantity
	        where PONumber = @current_PO_number and Product_Code = @PRODUCT_CODE
		set @start = @pos+1
       		GOTO DONE
	    END
	    ELSE
	    BEGIN
		set @RequiredQuantity = @RequiredQuantity - @Quantity
		UPDATE PODetail  set Pending = 0 where PONumber  = @current_PO_Number and Product_Code = @PRODUCT_CODE
	    END 
	END
	set @start = @pos+1
	select @pos = charindex ( ',' , @PONUMBERS, @start)
	
	if @pos = 0
	break
END 
	GOTO THEEND
THEEND:
 	select @current_PO_number = cast(substring(@PONUMBERS, @start, ((len(@PONUMBERS)+1) - @start)) as int)
	DECLARE UpdateQuantity CURSOR KEYSET FOR
	SELECT pending FROM PODETAIL WHERE PRODUCT_CODE = @PRODUCT_CODE AND PONumber = @current_PO_number
	open UpdateQuantity
	FETCH FROM UpdateQuantity INTO @Quantity
	CLOSE UpdateQuantity
	DEALLOCATE UpdateQuantity
	IF @@FETCH_STATUS = 0
	BEGIN
	    IF @Quantity >= @RequiredQuantity
	    BEGIN
	        UPDATE PODetail set Pending = Pending - @RequiredQuantity
	        where PONumber = @current_PO_number and Product_Code = @PRODUCT_CODE
       		GOTO DONE
	    END
	    ELSE
	    BEGIN
		set @RequiredQuantity = @RequiredQuantity - @Quantity
		UPDATE PODetail  set Pending = 0 where PONumber  = @current_PO_Number and Product_Code = @PRODUCT_CODE
	    END 
	END
DONE:


