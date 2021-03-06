CREATE PROCEDURE  SP_ACC_RPT_CALCULATE_ALLRATIOS (@FROMDATE DATETIME, @TODATE DATETIME)
AS
--BEGIN TRAN
CREATE TABLE #RATIOS
(
	RATIONAME			NVARCHAR(250),
	RATIONO				NUMERIC(9),
	GROUP1				NVARCHAR(100),
	GROUP1PARAMID		NVARCHAR(100),
	GROUP1BALANCE 		DECIMAL(18,6),
	GROUP2				NVARCHAR(100),
	GROUP2PARAMID		NVARCHAR(100),
	GROUP2BALANCE 		DECIMAL(18,6),
	RATIODESCRIPTION	NVARCHAR(250)
)

SET DATEFORMAT DMY
/* CALL THE PROCEDURE "SP_ACC_RPT_CALCULATE_INDV_RATIOS" TO CALCULATE RATIOS
   INPUT PARAMETERS  -> RATIO ID , FROM-DATE AND TO-DATE  
*/
/* 
	RATIOID = 1 -> CURRENT RATIO (CURRENT ASSETS + LIQUID ASSETS                  : CURRENT LIABILITIES)
	RATIOID = 2 -> QUICK   RATIO (QUICK   ASSETS (CURRENT ASSETS - CLOSING STOCK) : CURRENT LIABILITIES)
	RATIOID = 3 -> DEBT EQUITY RATIO (BORROWINGS + LOANS (LONG TREM LIABILITIES ) : CAPITAL & RESERVES & SURPLUS)
	RATIOID = 4	-> THIS CALCULATES 7 RATIOS (RATIOIDS -> 4,5,6,7,8,9,10) NAMELY
		1.GROSS PROFIT/LOSS RATIO 	: ((GROSS PROFIT/LOSS) / NET SALES ) * 100 --> 4
		2.NET   PROFIT/LOSS RATIO 	: ((NET   PROFIT/LOSS) / NET SALES ) * 100 --> 5
		3.OPERATING COST RATIO	  	: OPERATING COST / SALES*100		       --> 6
		4.RECEIVABLES TURN-OVER		: Sundry Debtors / Net sales * 100		   --> 7
		5.WORKING CAPITAL TURN-OVER : Net Sales / Working Capital 			   --> 8
		6.RETURN ON INVESTMENT		: Net Profit / Capital * 100			   --> 9
		7.RETURN ON WORKING CAPITAL	: Net Profit / Working Capital * 100 	   --> 10
*/

EXEC SP_ACC_RPT_CALCULATE_INDV_RATIOS 1 , @FROMDATE ,@TODATE --DESCRIPTION ON RATIOID -> REFER ABOVE
EXEC SP_ACC_RPT_CALCULATE_INDV_RATIOS 2 , @FROMDATE ,@TODATE --DESCRIPTION ON RATIOID -> REFER ABOVE
EXEC SP_ACC_RPT_CALCULATE_INDV_RATIOS 3 , @FROMDATE ,@TODATE --DESCRIPTION ON RATIOID -> REFER ABOVE
EXEC SP_ACC_RPT_CALCULATE_INDV_RATIOS 4 , @FROMDATE ,@TODATE --DESCRIPTION ON RATIOID -> REFER ABOVE
--EXEC SP_ACC_RPT_CALCULATE_INDV_RATIOS 7 , @FROMDATE ,@TODATE --DESCRIPTION ON RATIOID -> REFER ABOVE
/*
	PATINDEX FUNCTION : EQUIVALENT TO INSTR IN VB -> RETURNS THE POSITION WHERE THE PATTERN APPEARS
*/

/*
	63 REFERS TO DYNAMICSETTING20 IN FAREPORTDATA TABLE-> THIS SETTING TELLS WHICH FIELDSZ 
	ARE SUPPOSED TO HIODDEN AND VISIBLE.
	THIS HAS SAME DATA AS DYNAMICSETTING25 EXCEPT FOR THE HIDDEN COLUMNS ROWS
*/

/*
	UNION OPERATOR IS USED TO FETCH DETAILS FROM #RATIOS COZ OF THE FOLLOWING REASONS
	1.IF BOTH GROUP1BALANCE <> 0 AND GROUP2BALANCE <> 0 THEN CALCULATE RATIO
	2.IF GROUP1BALANCE = 0 AND GROUP2BALANCE <> 0 THEN THE RATIO WILL BE (0 : 1)-> BLIND SELECT
	3.IF (GROUP1BALANCE <> 0 AND GROUP2BALANCE = 0) OR (GROUP1BALANCE = 0 AND GROUP2BALANCE = 0 )
	  THEN "DIVIDE BY ZERO ERROR OCCURS" , SO DISPLAY IT AS 'INFINITY'
*/
SELECT 	RATIONAME AS 'Ratio Name',
	'Ratio ' = 
		CASE 		
			WHEN RATIONO IN (1,2,3) THEN SUBSTRING(CAST(GROUP1BALANCE / GROUP2BALANCE AS NCHAR),1,PATINDEX(N'%.%',CAST(GROUP1BALANCE / GROUP2BALANCE AS NCHAR)) + 2 )+ N' : 1'  
			WHEN RATIONO IN (4,5,6,9,10) THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS NCHAR),1,PATINDEX(N'%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS NCHAR))+ 2) + N' %'
			WHEN RATIONO IN (7) THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * DATEDIFF(DD,@FROMDATE,@TODATE)),2) AS NCHAR),1,PATINDEX(N'%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * DATEDIFF(DD,@FROMDATE,@TODATE) ),2) AS NCHAR))+ 2) + N' %'
			WHEN RATIONO IN (8) AND CAST((GROUP1BALANCE / GROUP2BALANCE ) AS DECIMAL(18,6)) > 0 THEN SUBSTRING(CAST(ROUND((CAST((GROUP1BALANCE / GROUP2BALANCE ) AS DECIMAL(18,6))),2) AS NCHAR),1,PATINDEX(N'%.%',CAST(ROUND((CAST((GROUP1BALANCE / GROUP2BALANCE ) AS DECIMAL(18,6))),2) AS NCHAR))+ 2) + N' : 1' ELSE dbo.LookupDictionaryItem('Not Calculatable',Default)
		END,
	RATIONO ,RATIODESCRIPTION as 'Ratio Description','0', @FROMDATE AS FROMDATE , @TODATE AS TODATE , '0' AS DOCREF ,'0' AS DOCTYPE , 'COLORINFO1 ' = '63',	'COLORINFO2 ' = '63'

FROM #RATIOS WHERE GROUP1BALANCE > 0 AND GROUP2BALANCE > 0
UNION
SELECT 	RATIONAME AS 'Ratio Name',
	'Ratio ' = 
		CASE 		
			WHEN RATIONO IN (4,5) THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS NCHAR),1,PATINDEX(N'%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS NCHAR))+ 2) + N' %' END,
	RATIONO ,RATIODESCRIPTION as 'Ratio Description','0', @FROMDATE AS FROMDATE , @TODATE AS TODATE , '0' AS DOCREF , '0' AS DOCTYPE , 'COLORINFO1 ' = '63', 'COLORINFO2 ' = '63'
FROM #RATIOS WHERE (RATIONO IN (4,5) ) AND (GROUP1BALANCE <= 0 OR GROUP2BALANCE <= 0)
UNION
SELECT 
	RATIONAME AS 'Ratio Name',
	'Ratio ' = dbo.LookupDictionaryItem('Not Calculatable',Default),
	RATIONO ,RATIODESCRIPTION as 'Ratio Description','0', @FROMDATE AS FROMDATE , @TODATE AS TODATE , '0' AS DOCREF , 
	'0' AS DOCTYPE , '63' AS COLORINFO1 ,'63' AS COLORINFO2
FROM #RATIOS WHERE GROUP1BALANCE <= 0 AND GROUP2BALANCE <> 0 AND RATIONO NOT IN (4,5)
UNION
SELECT 
	RATIONAME AS 'Ratio Name',
	'Ratio ' = dbo.LookupDictionaryItem('Not Calculatable',Default),
	RATIONO ,RATIODESCRIPTION as 'Ratio Description','0', @FROMDATE AS FROMDATE , @TODATE AS TODATE , '0' AS DOCREF , '0' AS DOCTYPE , '63' AS COLORINFO1 ,'63' AS COLORINFO2
FROM #RATIOS WHERE (GROUP1BALANCE <> 0 AND GROUP2BALANCE <= 0) OR (GROUP1BALANCE = 0 AND GROUP2BALANCE = 0 ) AND RATIONO NOT IN (4,5)
ORDER BY RATIONO
--COMMIT TRAN

/* USELESS CODE -> USE IT IF REQD LATER 
WHEN '1' THEN SUBSTRING(CAST(GROUP1BALANCE / GROUP2BALANCE AS CHAR),1,PATINDEX('%.%',CAST(GROUP1BALANCE / GROUP2BALANCE AS CHAR)) + 2 )+ ' : 1'  
WHEN '2' THEN SUBSTRING(CAST(GROUP1BALANCE / GROUP2BALANCE AS CHAR),1,PATINDEX('%.%',CAST(GROUP1BALANCE / GROUP2BALANCE AS CHAR)) + 2 )+ ' : 1'  
WHEN '3' THEN SUBSTRING(CAST(GROUP1BALANCE / GROUP2BALANCE AS CHAR),1,PATINDEX('%.%',CAST(GROUP1BALANCE / GROUP2BALANCE AS CHAR)) + 2 )+ ' : 1'  
WHEN '4','5' THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR))+ 2) 
WHEN '5' THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR))+ 2) 

WHEN '1' THEN SUBSTRING(CAST(ROUND(GROUP1BALANCE / GROUP2BALANCE,2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(GROUP1BALANCE / GROUP2BALANCE,2) AS CHAR)) + 2 )+ ' : 1'  
WHEN '2' THEN SUBSTRING(CAST(ROUND(GROUP1BALANCE / GROUP2BALANCE,2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(GROUP1BALANCE / GROUP2BALANCE,2) AS CHAR)) + 2 )+ ' : 1'  
WHEN '3' THEN SUBSTRING(CAST(ROUND(GROUP1BALANCE / GROUP2BALANCE,2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(GROUP1BALANCE / GROUP2BALANCE,2) AS CHAR)) + 2 )+ ' : 1'  
WHEN '4' THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR))+ 2) 
WHEN '4' THEN SUBSTRING(CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR),1,PATINDEX('%.%',CAST(ROUND(((GROUP1BALANCE / GROUP2BALANCE ) * 100 ),2) AS CHAR))+ 2) 
	
**/


