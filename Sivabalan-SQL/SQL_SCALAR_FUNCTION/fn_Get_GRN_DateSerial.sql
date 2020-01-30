
CREATE FUNCTION fn_Get_GRN_DateSerial(@BILLID Int)  
RETURNS nVarchar(1000)
AS
BEGIN  
 DECLARE @GRNDATESERIAL nVarchar(1000)
 DECLARE @GRNDATE nVarchar(12) 
 SET @GRNDATESERIAL = N''
 DECLARE GRN_Date_Cursor Cursor FOR 
 SELECT DISTINCT Cast(DatePart(dd, GRNDate) as Varchar) + N'/' + Cast(DatePart(mm, GRNDate) as Varchar) + N'/' + Cast(DatePart(yyyy, GRNDate) as Varchar) 
 FROM GRNAbstract WHERE BillID = @BILLID
 OPEN GRN_Date_Cursor
 FETCH NEXT FROM GRN_Date_Cursor INTO @GRNDATE
 WHILE @@FETCH_STATUS = 0 
    BEGIN
       IF LEN(@GRNDATESERIAL) = 0 
       SET @GRNDATESERIAL = @GRNDATE 
       ELSE
       SET @GRNDATESERIAL = @GRNDATESERIAL + ', ' + @GRNDATE
       FETCH NEXT FROM GRN_Date_Cursor INTO @GRNDATE
    END
 CLOSE GRN_Date_Cursor
 DEALLOCATE GRN_Date_Cursor
 RETURN @GRNDATESERIAL 
END

