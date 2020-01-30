CREATE FUNCTION GetSCAndDispatchDate(@INVNO INT, @TRANS nvarchar(10))      
RETURNS nvarchar(100)    
As      
BEGIN      
DECLARE @DispatchPrefix nvarchar(100)      
DECLARE @SCPrefix nvarchar(100)      
DECLARE @SCID nvarchar(100)    
DECLARE @DispatchID nvarchar(100)    
DECLARE @Result nvarchar(100)    
DECLARE @SCDate DATETIME    
DECLARE @DispatchDate DATETIME    
DECLARE @DispDate DATETIME    
DECLARE @SaleConDate DATETIME    
DECLARE @DispDates nvarchar(100)    
DECLARE @SCDates nvarchar(100)    
DECLARE @FormatDispDate nvarchar(100)    
DECLARE @FormatSCDate nvarchar(100)    
DECLARE @Refno nvarchar(50)    
    
SET @SCPrefix = dbo.GetVoucherPrefix(N'SALE CONFIRMATION') + N'%'    
SET @DispatchPrefix = dbo.GetVoucherPrefix(N'DISPATCH') + N'%'    
      
SELECT @DispatchID = Cast(IsNull(case when PatIndex(N'%[^0-9]%', ReferenceNumber) = 0 then ReferenceNumber else 0 end,0) as nvarchar) FROM InvoiceAbstract WHERE InvoiceID = @INVNO    
And NewReference Like @DispatchPrefix AND (Status & 128) = 0       
    
SELECT @SCID = Cast(IsNull(case when PatIndex(N'%[^0-9]%', ReferenceNumber) = 0 then ReferenceNumber else 0 end,0) as nvarchar) FROM InvoiceAbstract WHERE InvoiceID = @INVNO    
And NewReference Like @SCPrefix AND (Status & 128) = 0       
    
Set @DispDates = N''    
Set @SCDates = N''    
IF @DispatchID <> N''    
BEGIN    
/*  
 Select @Refno = RefNumber from DispatchAbstract WHere DispatchID = @DispatchID     
 And DispatchAbstract.NewRefNumber Like @SCPrefix AND (DispatchAbstract.Status & 64) = 0       
   */  
  
 Declare SCDate Cursor for     
 SELECT SODate FROM SOAbstract WHERE SONumber in (Select * From dbo.sp_SplitIn2Rows (@DispatchID, N','))    
 OPEN SCDate     
 FETCH FROM SCDate Into @SaleConDate    
 While @@fetch_status = 0     
 BEGIN              
 Set @FormatSCDate = N''    
 Set @FormatSCDate = Cast(Day(@SaleConDate) as nvarchar) + N'/' + Cast(Month(@SaleConDate)as nvarchar) + N'/' + Cast(Year(@SaleConDate)as nvarchar)    
 Set @SCDates = @SCDates + N',' + @FormatSCDate    
 FETCH NEXT FROM SCDate Into @SaleConDate    
 END     
 Close SCDate    
 Deallocate SCDate    
    
 Declare DispatchDate Cursor for    
 SELECT DispatchDate FROM DispatchAbstract WHERE DispatchID in (Select * From dbo.sp_SplitIn2Rows(@DispatchID, N','))    
 AND (DispatchAbstract.Status & 64) = 0       
 OPEN DispatchDate    
 FETCH FROM DispatchDate Into @DispDate    
 While @@fetch_status = 0               
 BEGIN      
 Set @FormatDispDate = N''    
 Set @FormatDispDate = Cast(Day(@DispDate) as nvarchar) + N'/' + Cast(Month(@DispDate)as nvarchar) + N'/' + Cast(Year(@DispDate)as nvarchar)    
 Set @DispDates = @DispDates + N',' + @FormatDispDate     
 FETCH NEXT FROM DispatchDate Into @DispDate    
 END     
 Close DispatchDate    
 Deallocate DispatchDate    
END    
ELSE IF @SCID <> N''     
BEGIN    
 SET @DispatchDate = NULL    
 Declare SCDate Cursor for    
 SELECT SODate FROM SOAbstract WHERE SONumber in (Select * From dbo.sp_SplitIn2Rows(@SCID, N','))    
 AND (Status & 64) = 0     
 OPEN SCDate     
 FETCH FROM SCDate Into @SaleConDate    
 While @@fetch_status = 0               
 BEGIN      
 Set @FormatSCDate = N''    
 Set @FormatSCDate = Cast(Day(@SaleConDate) as nvarchar) + N'/' + Cast(Month(@SaleConDate)as nvarchar) + N'/' + Cast(Year(@SaleConDate)as nvarchar)    
 Set @SCDates = @SCDates + N',' + @FormatSCDate     
 FETCH NEXT FROM SCDate Into @SaleConDate    
 END     
 Close SCDate    
 Deallocate SCDate    
END      
ELSE    
BEGIN    
 SET @DispDates = NULL    
 SET @SCDates = NULL    
END    
If Len(@SCDates) > 1     
 Set @SCDates = SubString(@SCDates , 2, Len(@SCDates) - 1)    
If Len(@DispDates) > 1     
 Set @DispDates = SubString(@DispDates , 2, Len(@DispDates) - 1)    
    
IF @TRANS = N'SC'    
 SET @Result = @SCDates    
ELSE    
 SET @Result = @DispDates    
    
RETURN @Result     
END      



