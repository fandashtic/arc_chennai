CREATE procedure sp_put_TOHeader 
(@DOCUMENTID int,  @DOCUMENTDATE datetime , @FORUMID nvarchar(50) , 
@NETVALUE Decimal(18,6), @STATUS int , @Prefix nvarchar(20), @TaxAmount Decimal(18,6),
@OriginalStockRequestNo int)
as

DECLARE @ORIGINALID AS nvarchar(25)
DECLARE @WAREHOUSEID AS nvarchar(25)

SET @ORIGINALID = @Prefix + cast(@DOCUMENTID as nvarchar)
SELECT @WAREHOUSEID = WAREHOUSEID FROM WAREHOUSE WHERE FORUMID = @FORUMID
--IF(@WAREHOUSEID  is null)	
--BEGIN			
--	SET @WAREHOUSEID = @FORUMID 	
--end

INSERT INTO STOCKTRANSFEROUTABSTRACTRECEIVED
( DocumentID, DocumentDate, WareHouseID, NetValue, Status , ForumCode , OriginalID, 
TaxAmount, OriginalStockRequest) 
VALUES (@DocumentID, @DocumentDate, @WareHouseID, @NetValue, @Status , 
@ForumId , @OriginalID, @TaxAmount, @OriginalStockRequestNo)
SELECT @@IDENTITY
