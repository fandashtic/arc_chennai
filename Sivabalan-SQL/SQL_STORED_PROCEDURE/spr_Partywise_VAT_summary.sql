CREATE PROCEDURE spr_Partywise_VAT_summary (@fromdate datetime, @todate datetime)
AS  

DECLARE @strsql  VARCHAR(8000) 	
DECLARE @strsql1 VARCHAR(8000)
DECLARE @strsqlUnion VARCHAR(8000)
DECLARE @ExecQry VARCHAR(8000)
DECLARE @ExecQry1 VARCHAR(8000)
DECLARE @ExecQry2 VARCHAR(8000)
DECLARE @ExecQry3 VARCHAR(8000)
DECLARE @ExecQry4 VARCHAR(8000)
DECLARE @strsql2 VARCHAR(8000)
DECLARE @strsql3 VARCHAR(8000)
DECLARE @strsql4 VARCHAR(8000)
DECLARE @Columns VARCHAR(8000)
DECLARE @InvoiceType INT
DECLARE @percentageid nVarchar(20)

--set @strsql = 'select "Slno" = IDENTITY( int,1,1), "Party Name" = customer.company_name'
set @strsql = 'select "Party Name" = customer.company_name'
--set @strsqlUnion = 'select "Slno" = IDENTITY( int,1,1), "Party Name" = Cash_customer.CustomerName'
set @strsqlUnion = 'select "Party Name" = case When customer.company_name Is Null then "Other Customers" else customer.company_name end'
set @strsql2 = ''
set @strsql3 = ''
set @strsql4 = ''
set @Columns = ''

DECLARE percentagecursor CURSOR FOR
Select Distinct InvoiceDetail.TCode
from 
     (
          Select InvoiceID 
          from InvoiceAbstract 
          where (InvoiceAbstract.Status & 128) = 0  
     )InvoiceAbstract, 
     (
          select InvoiceID, TaxCode + TaxCode2 as [TCode] 
          from InvoiceDetail 
          where InvoiceDetail.TaxCode <> 0 Or InvoiceDetail.TaxCode2 <> 0 
     ) InvoiceDetail 
WHERE  InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID 

OPEN percentagecursor	
FETCH NEXT FROM percentagecursor into @percentageid
	WHILE @@FETCH_STATUS =0
  		BEGIN
			SELECT @Columns = @Columns + '[' + @percentageid + '%],'

			SELECT @strsql1 = ',"' + @percentageid + '%" = sum( case when InvoiceAbstract.InvoiceType In (4, 5, 6) and InvoiceDetail.TaxCode = "'+ @percentageid + '" then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) when InvoiceAbstract.InvoiceType Not In (4, 5, 6) and (InvoiceDetail.TaxCode = "'+ @percentageid + '" or InvoiceDetail.TaxCode2 = "' + @percentageid + '") then invoicedetail.stPayable+invoicedetail.cstpayable else 0 end)'
			SELECT @strsql2 = @strsql2 + @strsql1
--            select @strsql2
	FETCH NEXT FROM percentagecursor into @percentageid
   	END	
CLOSE percentagecursor
DEALLOCATE percentagecursor 


SELECT @strsql3 = @strsql + @strsql2 + ',"Total" =  sum(case when InvoiceAbstract.InvoiceType in (4,5,6) then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) else invoicedetail.stPayable+invoicedetail.cstpayable end) into #temp from invoicedetail,invoiceabstract,customer where Customer.CustomerID = InvoiceAbstract.CustomerID and invoicedetail.invoiceid = invoiceabstract.invoiceid and invoiceabstract.invoicetype Not In (4, 5, 6) and InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 and (InvoiceAbstract.Status & 128) = 0 and InvoiceAbstract.InvoiceDate BETWEEN ' + '''' +  convert(varchar,@FROMDATE ) + '''' + ' AND ' + '''' + convert( varchar,@TODATE ) + '''' +' group by customer.company_name,Customer.CustomerID;'

SELECT @strsql4 = @strsqlUnion + @strsql2 + ',"Total" =  0- sum(stpayable+cstpayable) INTO #temp1 from invoiceabstract, customer, InvoiceDetail where Customer.CustomerID = InvoiceAbstract.CustomerID and invoicedetail.invoiceid = invoiceabstract.invoiceid and invoiceabstract.invoicetype In (4, 5, 6) and InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 and (InvoiceAbstract.Status & 128) = 0 and InvoiceAbstract.InvoiceDate BETWEEN ' + '''' +  convert(varchar,@FROMDATE ) + '''' + ' AND ' + '''' + convert( varchar,@TODATE ) + '''' +' group by customer.company_name,Customer.CustomerID'

SELECT @ExecQry = @strsql3
--SELECT @ExecQry = @ExecQry + '; INSERT #temp([Party Name],' + @Columns + 'Total) SELECT [Party Name], ' + @Columns + 'Total FROM #temp1'
--SELECT @ExecQry = @ExecQry + '; INSERT INTO #temp([Party Name]) VALUES("Grand Total");'
--SELECT @ExecQry = @ExecQry + 'UPDATE #temp SET [Total]=(SELECT SUM(Total) FROM #temp) WHERE [Party Name] = "Grand Total" AND Total is null; select * into #temp from #temp1; ALTER TABLE #temp2 ALTER COLUMN Slno INT; UPDATE #temp2 SET Slno=NULL WHERE Slno =(SELECT MAX(Slno) FROM #temp2); SELECT * FROM #TEMP2 WHERE Total <> 0 ORDER BY SerialNo; DROP TABLE #temp, #temp1, #temp2 ' --DROP TABLE #temp'

--SELECT @ExecQry 
SELECT @ExecQry1 =  '; INSERT #temp([Party Name],' + @Columns + 'Total) SELECT [Party Name], ' + @Columns + 'Total FROM #temp1'
--SELECT @ExecQry2 =  '; INSERT INTO #temp([Party Name]) VALUES("Grand Total");'
SELECT @ExecQry2 =  ';'
SELECT @ExecQry3 =  'UPDATE #temp SET [Total]=(SELECT SUM(Total) FROM #temp) WHERE [Party Name] = "Grand Total" AND Total is null; SELECT "Customer_Name" = [Party Name],* FROM #TEMP WHERE Total <> 0 order by Total ; DROP TABLE #temp, #temp1' --DROP TABLE #temp'

EXEC(@ExecQry+@strsql4 + @ExecQry1+ @ExecQry2 + @ExecQry3)



