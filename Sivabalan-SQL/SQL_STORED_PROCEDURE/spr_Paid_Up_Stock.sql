CREATE Procedure spr_Paid_Up_Stock	( @PERIOD nvarchar(15)	)
AS
DECLARE @AGG Decimal(18,6)
DECLARE @BALANCE Decimal(18,6)
DECLARE @DRNOTES Decimal(18,6)
DECLARE @CRNOTES Decimal(18,6)
DECLARE @AVGSALES Decimal(18,6)
Declare @Advance Decimal(18,6)
Declare @PurchaseReturn Decimal(18,6)
DECLARE @EffectiveStock Decimal(18,6) -- variable to store the effective stock calculated
DECLARE @TotalStockValue Decimal(18,6) 
DECLARE @FROMDATE DATETIME
DECLARE @TODATE DATETIME
DECLARE @TOTALPENDING Decimal(18,6)
DECLARE @Month int
SET @AGG = cast(substring(@PERIOD,1,2) as int)
SET @FROMDATE = CAST(DATEPART(dd, GETDATE()) AS nvarchar) + '/' + CAST(DATEPART(mm, GETDATE()) as nvarchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS nvarchar)
Set @Month = cast(substring(@PERIOD,1,2) as int)
SET @FROMDATE = DATEADD(m, (0- @Month), @FROMDATE)

SET @TODATE = CAST(DATEPART(dd, GETDATE()) AS nvarchar) + '/' + CAST(DATEPART(mm, GETDATE()) as nvarchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS nvarchar)
SET  @TODATE = DATEADD(d, 1, @TODATE)
select @TotalStockValue = ISNULL(sum(Quantity * PurchasePrice), 0) from Batch_Products 
Select @Balance =  ISNULL(sum(Balance), 0) from BillAbstract 
where Status & 128 = 0 And Balance > 0
Select @DRNOTES =  ISNULL(sum(Balance), 0) from DebitNote 
Where VendorID Is Not Null And Balance > 0
Select @CRNOTES =  ISNULL(sum(Balance), 0) from CreditNote 
Where VendorID Is Not Null And Balance > 0
Select @Advance = IsNull(Sum(Balance), 0) From Payments 
Where Balance > 0 And IsNull(status, 0) & 128 = 0
Select @PurchaseReturn = IsNull(Sum(Balance), 0) From AdjustmentReturnAbstract
Where Balance > 0 And IsNull(Status, 0) & 128 = 0
SET @TOTALPENDING = @Balance + @CRNOTES - @Advance - @DRNOTES - @PurchaseReturn
select @AVGSALES = isnull(sum((Case InvoiceType When 4 Then -1 Else 1 End) * (NetValue - Freight)),0) from InvoiceAbstract
	where status & 128 = 0 and Invoicedate between @fromdate and @todate
Select 1, "Total Stock Value (%c)" = cast((@TotalStockValue) as Decimal(18,6) ), "Total Pending (%c)" = @TOTALPENDING ,
"Effective Paid-Up (%c)" = @TotalStockValue - @TOTALPENDING,
"Average Monthly Sales (%c)" = @AvgSales / @Month,
"Paid-Up (Days)"= cast((((@TotalStockValue - @TOTALPENDING)) / (case @AvgSales when 0 then 1 else @AvgSales  end )) * 30 as Decimal(18,6))


