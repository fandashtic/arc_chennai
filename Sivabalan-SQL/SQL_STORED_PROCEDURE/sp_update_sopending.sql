CREATE PROCEDURE sp_update_sopending
(
@PRODUCT_CODE nvarchar(15),
@RequiredQuantity Decimal(18,6),
@SONUMBERS NVARCHAR(255),
@FREEFLAG int = -1
)
AS
declare @string nvarchar(255)
declare @current_SO_number int
declare @sos int
declare @start int
declare @Quantity Decimal(18,6)

set @start = 1
select @sos = charindex ( ',' , @SONUMBERS , @start)
IF @sos = 0
	SET @sos = len(@SONUMBERS)+1
while  @sos <> 0
begin
--storing the current so number obtained after splitting and casting --
 	select @current_SO_number = cast(substring(@SONUMBERS, @start, (@sos - @start)) as int)
--cursor code --
	-- The @FREEFLAG declared and used to find the free stock or saleable stock 
	If @FREEFLAG = 1
	Begin
		DECLARE UpdateQuantity CURSOR FOR
		SELECT ISNULL(pending,0) FROM SODETAIL 
	  WHERE PRODUCT_CODE = @PRODUCT_CODE 
		AND SONumber = @current_SO_number
		And SalePrice = 0
	End
	Else If @FREEFLAG = 0
	Begin
		DECLARE UpdateQuantity CURSOR FOR
		SELECT ISNULL(pending,0) FROM SODETAIL 
	  WHERE PRODUCT_CODE = @PRODUCT_CODE 
		AND SONumber = @current_SO_number
		And SalePrice <> 0
  End
	Else
	Begin
		DECLARE UpdateQuantity CURSOR FOR
		SELECT ISNULL(pending,0) FROM SODETAIL 
	  WHERE PRODUCT_CODE = @PRODUCT_CODE 
		AND SONumber = @current_SO_number
	End
  open UpdateQuantity
	FETCH FROM UpdateQuantity INTO @Quantity
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    IF @Quantity >= @RequiredQuantity
	    BEGIN
	        UPDATE SODetail set Pending = Pending - @RequiredQuantity
	        where current of UpdateQuantity
       		GOTO OVERNOUT
	    END
	    ELSE
	    BEGIN
			set @RequiredQuantity = @RequiredQuantity - @Quantity
			UPDATE SODetail  set Pending = 0 where current of UpdateQuantity
	    END 
		FETCH Next FROM UpdateQuantity INTO @Quantity
	END
	Close UpdateQuantity
	Deallocate UpdateQuantity
	IF @sos >= len(@SONUMBERS) break
	set @start = @sos+1
	select @sos = charindex ( ',' , @SONUMBERS, @start)
	
	if @sos = 0
		SET @sos = len(@SONUMBERS)+1
END 
	GOTO THEEND
OVERNOUT:
	Close UpdateQuantity
	Deallocate UpdateQuantity
THEEND:
SELECT 1
