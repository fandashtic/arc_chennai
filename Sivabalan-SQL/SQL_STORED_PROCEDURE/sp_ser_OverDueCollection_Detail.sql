
CREATE Procedure sp_ser_OverDueCollection_Detail(@ITEM nvarchar(2550))  
as  
Declare @ParamSep As Char(1), @ParamSepcounter as Int
Declare @tempString As NVarchar(2550)
Declare @CustomerID as NVarchar(30)
Declare @ChannelType as Int
Declare @BeatID as Int
Declare @SalesmanID as Int
Declare @FromDate as Int
Declare @ToDate as Int
Declare @INV as NVarchar(50)

Set @tempString = @ITEM
Set @ParamSep = Char(2)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'    

/*
    CustomerID + Char(2) + ChannelType + Char(2) + BeatID + Char(2) + SlaesmanID
*/
/* CustomerID */
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)
set @CustomerID = substring(@tempString, 1, @ParamSepcounter-1)

/* ChannelType */
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)
set @ChannelType = Convert(Int, substring(@tempString, 1, @ParamSepcounter-1))

/* BeatID */
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)
set @BeatID = Convert(Int, substring(@tempString, 1, @ParamSepcounter-1))

/* SalesmanID */
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)
set @SalesmanID = Convert(Int, substring(@tempString, 1, @ParamSepcounter-1))

/* FromDate */
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)
set @FromDate = Convert(Int, substring(@tempString, 1, @ParamSepcounter-1))

/* ToDate */
set  @ToDate = Convert(Int, substring(@tempString, @ParamSepcounter+1, len(@ITEM)))


Select 
--Refered with Existing Doc ID and DocReference
"InvoiceID" = InvoiceID
,"InvoiceID" = @INV + CAST(INVABS.DocumentID AS nVARCHAR)
,"Doc Ref" = INVABS.DocReference 
,"Invoice Date" = INVABS.InvoiceDate
,"Invoice Amount" = INVABS.NetValue
,"Balance" = INVABS.Balance
,"Overdue" = CASE 
        WHEN Convert(Int ,Convert(NVarchar ,INVABS.PaymentDate,112)) < Convert(Int ,Convert(NVarchar ,GetDate(),112)) Then INVABS.Balance
        ELSE 0
        END
,"CreditTerm Days" = DateDIff(d ,INVABS.InvoiceDate ,INVABS.PaymentDate)
,"Overdue Date" = Convert(NVarchar(10),INVABS.PaymentDate,103)
,"Days left for Overdue" = DateDIff(d ,GetDate() ,INVABS.PaymentDate)
from InvoiceAbstract INVABS
INNER JOIN Customer CUST ON CUST.CustomerID = INVABS.CustomerID
--- InCase of Name of following Masters is duplicated then following are needed
--LEFT OUTER JOIN  Customer_Channel CHNL ON CHNL.CustomerID = INVABS.CustomerID
--LEFT OUTER JOIN  Beat BEET  ON BEET.CustomerID = INVABS.CustomerID
--LEFT OUTER JOIN  Salesman SMAN ON SMAN.SalesmanID = INVABS.SalesmanID
Where 
INVABS.InvoiceType in (1,3) AND IsNull(INVABS.Status,0) & 128 = 0
AND INVABS.CustomerID = @CustomerID
AND IsNull(INVABS.BeatID,0) = @BeatID
AND IsNull(INVABS.SalesmanID,0) = @SalesmanID
AND IsNull(CUST.ChannelType,0) = @ChannelType   
AND Convert(NVarchar,INVABS.InvoiceDate,112) Between @FromDate
    AND @ToDate
