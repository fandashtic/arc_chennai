CREATE PROCEDURE SP_ACC_RPT_CALCULATE_INDV_RATIOS 
	(
		@RATIOID 	INT, 
		@FROMDATE 	DATETIME, 
		@TODATE 	DATETIME
	)
AS
	SET DATEFORMAT DMY
	/* VARIABLE DECLARATION */
	DECLARE @BALANCE 						DECIMAL(18,6) 	--VARIABLE TO STORE THE BALANCE RETRIEVED BASIS THE GROUP ID
	DECLARE @CURRENTASSETS					INT	      		--VARIABLE TO STORE THE CURRENT ASSET GROUP ID -> ACCOUNTSGROUP MASTER
	DECLARE @CURRENTLIABILITIES				INT	      		--VARIABLE TO STORE THE CURRENT LIABILITIES GROUP ID -> ACCOUNTSGROUP MASTER
	DECLARE @CURRENTLIABILITIES_PROVISIONS	INT	      		--VARIABLE TO STORE THE CURRENT LIABILITIES & PROVISIONS GROUP ID -> ACCOUNTSGROUP MASTER
	DECLARE @CLOSINGSTOCK					INT	      		--VARIABLE TO STORE THE CLOSING STOCK GROUP ID -> ACCOUNTSGROUP MASTER
	DECLARE @RATIONAME						NVARCHAR(250)	--VARIABLE TO STORE THE RATIO DESCRIPTION
	DECLARE @LOANSADVANCES					INT				--VARIABLE TO STORE THE LOANS $ ADVANCESGROUP ID -> ACCOUNTSGROUP MASTER
	DECLARE @GROSSPROFIT					DECIMAL(18,6)
	DECLARE @NETPROFIT						DECIMAL(18,6)
	DECLARE @GROSSLOSS						DECIMAL(18,6)
	DECLARE @NETLOSS						DECIMAL(18,6)
	DECLARE @NETSALES						DECIMAL(18,6)	
	DECLARE @PERCENTAGE						NVARCHAR(250)
	DECLARE @BORROWING_SHRT_TERM			INT				--VARIABLE TO STORE THE BORROWINGS SHORT TERM GROUP ID
	DECLARE @LOANS_LONGTERM_LIABILITIES		INT				--VARIABLE TO STORE THE LOANS LONGTERM LIABILITIES GROUP ID
	DECLARE @CAPITAL_RESERVES_SURPLUS		INT				--VARIABLE TO STORE THE CAPITAL & (RESERVES & SURPLUS) GROUP ID
	DECLARE @OPERATINGCOST					DECIMAL(18,6)   --VARIABLE TO STORE THE OPERATING COST AMOUNT WHICH IS NET SALES - NET PROFIT
	DECLARE @SUNDRYDEBTORS					INT	
	DECLARE @WORKINGCAPITAL					DECIMAL(18,6)	--VARIABLE TO STORE THE WORKING CAPITAL AMOUNT WHICH IS CURRENT ASSETS - CURRENT LIABILITIES

	/* VALUE ASSIGNMENT */	
	SET @CURRENTASSETS 					= 17
	SET @CURRENTLIABILITIES 			= 56
	SET @LOANSADVANCES					= 16
	SET @CURRENTLIABILITIES_PROVISIONS	= 8 
	SET @CLOSINGSTOCK					= 55
	SET @BORROWING_SHRT_TERM			= 6
	SET @LOANS_LONGTERM_LIABILITIES		= 3
	SET @CAPITAL_RESERVES_SURPLUS		= 1
	SET @SUNDRYDEBTORS					= 22

	/* CALL THE PROCEDURE "SP_ACC_RPT_RATIOSRECURSIVEBALANCE" TO RETRIEVE BALANCE 
	   AVAILABLE UNDER EACH GROUP. 
	   INPUT PARAMETERS  -> GROUP ID , FROM-DATE AND TO-DATE  
	   OUTPUT PARAMETERS -> BALANCE OF THE PARTICULAR GROUP
	*/
	/* 
		RATIOID = 1 -> CURRENT RATIO (CURRENT ASSETS + LIQUID ASSETS                  : CURRENT LIABILITIES)
		RATIOID = 2 -> QUICK   RATIO (QUICK   ASSETS (CURRENT ASSETS - CLOSING STOCK) : CURRENT LIABILITIES)
		RATIOID	= 3	-> DEBT EQUITY RATIO (BORROWINGS + LOANS (LONG TREM LIABILITIES ) : CAPITAL & RESERVES & SURPLUS)
		--GROSS PROFIT RATIO (GROSS PROFIT / SALES) % 100 

	*/
	IF @RATIOID = 1
		BEGIN
			SET @RATIONAME = dbo.LookupDictionaryItem('CURRENT RATIO',Default)
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTASSETS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* INSERT THE BALANCE RETREIVED FROM PROCEDURE TO THE TEMP TABLE WITH THE RATIO ID */
			INSERT INTO #RATIOS (RATIONO,RATIONAME ,GROUP1 ,GROUP1BALANCE ,GROUP1PARAMID ,RATIODESCRIPTION)
			SELECT '1',@RATIONAME , dbo.LookupDictionaryItem('CURRENT ASSETS',Default) ,@BALANCE ,@CURRENTASSETS ,dbo.LookupDictionaryItem('Current Assets : Current Liabilities',Default)

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE  @LOANSADVANCES , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */

			UPDATE #RATIOS
			SET 	
				GROUP1BALANCE 	= GROUP1BALANCE + @BALANCE ,
				GROUP1PARAMID	= GROUP1PARAMID + N'~' + LTRIM(RTRIM(CAST(@LOANSADVANCES AS NCHAR)))
				/* PROVISIONS VALUE COMES IN -VE SO CHANGE IT TO POSITIVE USING ABS FUNCTION */
			WHERE
				RATIONAME = @RATIONAME


			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTLIABILITIES_PROVISIONS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
			IF @BALANCE < 0 
				BEGIN
					UPDATE #RATIOS
					SET GROUP2 			= dbo.LookupDictionaryItem('CURRENT LIABILITIES',Default) ,
						GROUP2BALANCE 	= ABS(@BALANCE),
						GROUP2PARAMID	= @CURRENTLIABILITIES_PROVISIONS
					WHERE
						RATIONAME = @RATIONAME
				END
			ELSE
				BEGIN
					UPDATE #RATIOS
					SET GROUP2 			= dbo.LookupDictionaryItem('CURRENT LIABILITIES',Default) ,
						GROUP2BALANCE 	= @BALANCE * -1 ,

						GROUP2PARAMID	= @CURRENTLIABILITIES_PROVISIONS
					WHERE
						RATIONAME = @RATIONAME
				END

-- -- -- -- 			SET @BALANCE = 0
-- -- -- -- 			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTLIABILITIES_PROVISIONS , @FROMDATE , @TODATE , @BALANCE OUTPUT
-- -- -- -- 			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
-- -- -- -- 			UPDATE #RATIOS
-- -- -- -- 			SET 	
-- -- -- -- 				GROUP2BALANCE 	= GROUP2BALANCE + @BALANCE ,
-- -- -- -- 				GROUP2PARAMID	= GROUP2PARAMID + '~' + LTRIM(RTRIM(CAST(@CURRENTLIABILITIES_PROVISIONS AS CHAR)))
-- -- -- -- 				/* PROVISIONS VALUE COMES IN -VE SO CHANGE IT TO POSITIVE USING ABS FUNCTION */
-- -- -- -- 			WHERE
-- -- -- -- 				RATIONAME = @RATIONAME
		END
	ELSE IF @RATIOID = 2
		BEGIN
			SET @RATIONAME = dbo.LookupDictionaryItem('QUICK RATIO',Default) 
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTASSETS , @FROMDATE , @TODATE  , @BALANCE OUTPUT ,2
			/* INSERT THE BALANCE RETREIVED FROM PROCEDURE TO THE TEMP TABLE WITH THE RATIO ID */
			INSERT INTO #RATIOS (RATIONO, RATIONAME ,GROUP1 ,GROUP1BALANCE ,GROUP1PARAMID ,RATIODESCRIPTION)
			SELECT '2', @RATIONAME , dbo.LookupDictionaryItem('CURRENT ASSETS',Default) ,@BALANCE ,@CURRENTASSETS ,dbo.LookupDictionaryItem('Quick Assets [Current Assets - Closing Stock]  : Current Liabilities',Default)

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE  @LOANSADVANCES , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
			UPDATE #RATIOS
			SET 	
				GROUP1BALANCE 	= GROUP1BALANCE + @BALANCE ,
				GROUP1PARAMID	= GROUP1PARAMID + N'~' + LTRIM(RTRIM(CAST(@LOANSADVANCES AS NCHAR)))
				/* PROVISIONS VALUE COMES IN -VE SO CHANGE IT TO POSITIVE USING ABS FUNCTION */
			WHERE
				RATIONAME = @RATIONAME

-- -- -- -- 			SET @BALANCE = 0
-- -- -- -- 			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CLOSINGSTOCK , @FROMDATE , @TODATE , @BALANCE OUTPUT
-- -- -- -- 			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
-- -- -- -- 			UPDATE #RATIOS
-- -- -- -- 			SET 	
-- -- -- -- 				GROUP1BALANCE 	= GROUP1BALANCE - @BALANCE,
-- -- -- -- 				GROUP1PARAMID	= GROUP1PARAMID + '~' + LTRIM(RTRIM(CAST(@CLOSINGSTOCK AS CHAR)))
-- -- -- -- 			WHERE
-- -- -- -- 				RATIONAME = @RATIONAME
			--SELECT * FROM #RATIOS

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTLIABILITIES_PROVISIONS  , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
			IF @BALANCE < 0 
				BEGIN
					UPDATE #RATIOS
					SET GROUP2 			= dbo.LookupDictionaryItem('CURRENT LIABILITIES',Default) ,
						GROUP2BALANCE 	= ABS(@BALANCE),
						GROUP2PARAMID	= @CURRENTLIABILITIES_PROVISIONS
					WHERE
						RATIONAME = @RATIONAME
				END
			ELSE
				BEGIN
					UPDATE #RATIOS
					SET GROUP2 			= dbo.LookupDictionaryItem('CURRENT LIABILITIES',Default) ,
						GROUP2BALANCE 	= @BALANCE * -1,
						GROUP2PARAMID	= @CURRENTLIABILITIES_PROVISIONS
					WHERE
						RATIONAME = @RATIONAME
				END
-- -- -- 			SET @BALANCE = 0
-- -- -- 			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTLIABILITIES_PROVISIONS , @FROMDATE , @TODATE , @BALANCE OUTPUT
-- -- -- 			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
-- -- -- 			UPDATE #RATIOS
-- -- -- 			SET 	
-- -- -- 				GROUP2BALANCE 	= GROUP2BALANCE + @BALANCE,
-- -- -- 				GROUP2PARAMID	= GROUP2PARAMID	+ '~' + LTRIM(RTRIM(CAST(@CURRENTLIABILITIES_PROVISIONS AS CHAR)))
-- -- -- 				/* PROVIDIONS VALUE COMES IN -VE SO CHANGE IT TO POSITIVE USING ABS FUNCTION */
-- -- -- 			WHERE
-- -- -- 				RATIONAME = @RATIONAME
		END

	ELSE IF @RATIOID = 3 --DEBT EQUITY RATIO
		BEGIN

			SET @RATIONAME = dbo.LookupDictionaryItem('DEBT EQUITY RATIO',Default) 
			SET @BALANCE = 0			
			/* FIND THE BORROWING_SHRT_TERM TOTAL AND INSERT INTO #RATIOS TABLE */
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @BORROWING_SHRT_TERM , @FROMDATE , @TODATE  , @BALANCE OUTPUT
			/* INSERT THE BALANCE RETREIVED FROM PROCEDURE TO THE TEMP TABLE WITH THE RATIO ID */
			INSERT INTO #RATIOS (RATIONO, RATIONAME ,GROUP1 ,GROUP1BALANCE ,GROUP1PARAMID ,RATIODESCRIPTION)
			SELECT '3', @RATIONAME , dbo.LookupDictionaryItem('DEBT [BORROWINGS + LOANS]',Default) ,@BALANCE ,@BORROWING_SHRT_TERM ,dbo.LookupDictionaryItem('Debt [Short Term and Long Term Borrowings] : Capital Accounts',Default)

			/* ADD THE NEXT GROUP WITH THE FIRST ONE */			
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE  @LOANS_LONGTERM_LIABILITIES , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
			UPDATE #RATIOS
			SET 	
				GROUP1BALANCE 	= GROUP1BALANCE + @BALANCE ,
				GROUP1PARAMID	= GROUP1PARAMID + N'~' + LTRIM(RTRIM(CAST(@LOANS_LONGTERM_LIABILITIES AS NCHAR)))
			WHERE
				RATIONAME = @RATIONAME

			/* FOR GROUP2 */
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CAPITAL_RESERVES_SURPLUS  , @FROMDATE , @TODATE , @BALANCE OUTPUT
			/* UPDATE THE BALANCE TO THE TEMP TABLE AGAINST THE RATIONAME */
			IF @BALANCE < 0 
				BEGIN
					UPDATE #RATIOS
					SET GROUP2 			= dbo.LookupDictionaryItem('CAPITAL ACCOUNTS',Default) ,
						GROUP2BALANCE 	= ABS(@BALANCE),
						GROUP2PARAMID	= @CAPITAL_RESERVES_SURPLUS
					WHERE
						RATIONAME = @RATIONAME
				END
			ELSE			
				BEGIN
					UPDATE #RATIOS
					SET GROUP2 			= dbo.LookupDictionaryItem('CAPITAL ACCOUNTS',Default) ,
						GROUP2BALANCE 	= @BALANCE * -1,
						GROUP2PARAMID	= @CAPITAL_RESERVES_SURPLUS
					WHERE
						RATIONAME = @RATIONAME
				END

		END
	ELSE IF @RATIOID = 4 
		BEGIN 
			SET @RATIONAME = dbo.LookupDictionaryItem('GROSS PROFIT/LOSS RATIO',Default) 
			CREATE TABLE #TEMPTRADINGDETAILS
			(
				ACCOUNTNAME 	NVARCHAR(25),
				AMOUNT 			DECIMAL(18,6),
				DUMMY1 			NCHAR(10),
				ACCOUNTID 		INT,
				FROMDATE 		DATETIME,
				TODATE 			DATETIME,
				DOCREF 			INTEGER,
				DOCTYPE 		INTEGER,
				COLORINFO1 		INT,
				DIFFERENCEAMT 	DECIMAL(18,6),
				COLORINFO2 		NVARCHAR(10)
			)
			/*
				INSERT THE P&L VALUES TO A TEMP TABLE
			*/
			INSERT INTO #TEMPTRADINGDETAILS
			EXEC SP_ACC_RPT_TRADINGAC @FROMDATE,@TODATE,'1' 
			/* 
			GET THE GROSS PROFIT FROM THE TEMP TABLE
			*/
			/* 
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO GROSS PROFIT/LOSS RATIO
			*/
			SET @GROSSPROFIT = 0
			SET @GROSSLOSS = 0
			SELECT @GROSSPROFIT = AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Gross Profit')
			SELECT @GROSSLOSS = AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Gross Loss')
			SELECT @NETSALES	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) = N'Sales Account'
			IF @GROSSPROFIT > 0 
				BEGIN
					SELECT @PERCENTAGE 	= CAST(ROUND(((@GROSSPROFIT / @NETSALES ) * 100 ),2) AS NCHAR)
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('GROSS PROFIT/LOSS',Default),'0',@GROSSPROFIT,
						   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('(Gross Profit or Gross Loss) / Net Sales * 100',Default)
				END
			ELSE
				BEGIN
					SELECT @PERCENTAGE 	= CAST(ROUND(((@GROSSLOSS / @NETSALES ) * 100 * -1 ),2) AS NCHAR)
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('GROSS PROFIT/LOSS',Default),'0',@GROSSLOSS * -1,
						   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('(Gross Profit or Gross Loss) / Net Sales * 100',Default)
				END

			/*==================================================================================*/
			/*RATIOID = 5 */
			/* 
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO NET PROFIT/LOSS RATIO
			*/
			SET @RATIONAME 	= dbo.LookupDictionaryItem('NET PROFIT/LOSS RATIO',Default) 
			SET @RATIOID	= 5
			SET @NETPROFIT = 0
			SET @NETLOSS = 0
			SELECT @NETPROFIT 	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Profit')
			SELECT @NETLOSS 	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Loss')
			SELECT @NETSALES	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) = N'Sales Account'
			IF @NETPROFIT > 0 
				BEGIN
					SELECT @PERCENTAGE 	= CAST(ROUND(((@NETPROFIT / @NETSALES ) * 100 ),2) AS NCHAR)
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('NET PROFIT/LOSS',Default),'0',@NETPROFIT,
					   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('(Net Profit or Net Loss) / Net Sales * 100',Default)
				END
			ELSE
				BEGIN
					SELECT @PERCENTAGE 	= CAST(ROUND(((@NETLOSS / @NETSALES ) * 100 * -1 ),2) AS NCHAR)
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('NET PROFIT/LOSS',Default),'0',@NETLOSS * -1,
					   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('(Net Profit or Net Loss) / Net Sales * 100',Default)
				END

			/*==================================================================================*/
			/*RATIOID = 6 */
			/*
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO OPERATING COST RATIO
			*/
			SET @RATIONAME 	= dbo.LookupDictionaryItem('OPERATING COST RATIO',Default) 
			SET @RATIOID	= 6

			SET @NETPROFIT = 0
			SET @NETLOSS = 0
			SELECT @NETLOSS 	= ISNULL(AMOUNT,0) FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Loss')
			SELECT @NETPROFIT 	= ISNULL(AMOUNT,0) FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Profit')
			SELECT @NETSALES	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) = N'Sales Account'
			/* OPERATING COST = NET SALES - NET PROFIT */
			--SELECT @NETSALES , @NETPROFIT
			IF @NETPROFIT > 0 
				BEGIN
					SET @OPERATINGCOST 	= @NETSALES - @NETPROFIT
					SELECT @PERCENTAGE 	= CAST(ROUND(((@OPERATINGCOST / @NETSALES ) * 100 ),2) AS NCHAR)
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('OPERATING COST',Default),'0',@OPERATINGCOST,
						   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('Operating Cost [Net Sales - Net Profit] / Net Sales * 100',Default)
				END
			ELSE
				BEGIN
					/* IF NETLOSS THEN RATIOS IS 0 */
					SET @OPERATINGCOST 	= 0
					SELECT @PERCENTAGE 	= 0
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('OPERATING COST',Default),'0',@OPERATINGCOST,
						   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('Operating Cost [Net Sales - Net Profit] / Net Sales * 100',Default)

				END
				
			/*==================================================================================*/
			/*RATIOID = 7 */
			/*
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO RECEIVALBLES TURN OVER
			RECEIVALBLES TURN OVER = SUNDRY DEBTORS / NET SALES * NO OF DAYS (PROBABLY NO OF DAYS BETWEEN FROM DATE AND TO DATE)
			*/
			SET @RATIONAME 	= dbo.LookupDictionaryItem('RECEIVABLES TURN-OVER',Default) 
			SET @RATIOID	= 7

			SELECT @NETSALES	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) = dbo.LookupDictionaryItem('Sales Account',Default)
			/* GET THE SUNDRY DEBTORS BALANCE */
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE  @SUNDRYDEBTORS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			INSERT INTO #RATIOS
			SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('SUNDRY DEBTORS',Default),'0',@BALANCE, 
				   dbo.LookupDictionaryItem('SALES',Default),'0',@NETSALES ,dbo.LookupDictionaryItem('(Sundry Debtors / Net sales) * No. of Days',Default) 

			/*==================================================================================*/
			/*RATIOID = 8 */
			/*
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO WORKING CAPITAL TURN-OVER
			WORKING CAPITAL TURN-OVER : NET SALES / WORKING CAPITAL 
				WORKING CAPITAL = CURRENT ASSET - CURRENT LIABILITIES
			*/

			SET @RATIONAME 	= dbo.LookupDictionaryItem('WORKING CAPITAL TURN-OVER',Default) 
			SET @RATIOID	= 8
			/* GET THE CURRENT ASSETS BALANCE */
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTASSETS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			SET @WORKINGCAPITAL = @BALANCE
			/* GET THE LIABILITIES BALANCE*/
			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @LOANSADVANCES , @FROMDATE , @TODATE , @BALANCE OUTPUT
			SET @WORKINGCAPITAL = @WORKINGCAPITAL + @BALANCE

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTLIABILITIES_PROVISIONS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			IF @BALANCE < 0
				SET @WORKINGCAPITAL = @WORKINGCAPITAL + @BALANCE
			ELSE
				SET @WORKINGCAPITAL = @WORKINGCAPITAL - @BALANCE

			SELECT @NETSALES	= AMOUNT FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) = dbo.LookupDictionaryItem('Sales Account',Default)			

			INSERT INTO #RATIOS
			SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('NET SALES',Default),'0',@NETSALES, 
				   dbo.LookupDictionaryItem('WORKINGCAPITAL',Default),'0',@WORKINGCAPITAL,dbo.LookupDictionaryItem('Net Sales / Working Capital',Default) 

			/*==================================================================================*/
			/*RATIOID = 9 */
			/*
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO OPERATING COST RATIO
			*/
			SET @RATIONAME 	= dbo.LookupDictionaryItem('RETURN ON INVESTMENT',Default) 
			SET @RATIOID	= 9
			
			SELECT @NETPROFIT 	= ISNULL(AMOUNT,0) FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Loss')
			SELECT @NETPROFIT 	= ISNULL(AMOUNT,0) FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Profit')

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CAPITAL_RESERVES_SURPLUS , @FROMDATE , @TODATE , @BALANCE OUTPUT

			INSERT INTO #RATIOS
			SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('NET PROFIT',Default),'0',@NETPROFIT,
				   dbo.LookupDictionaryItem('CAPITAL RESERVES SURPLUS',Default),'0',@BALANCE ,dbo.LookupDictionaryItem('Net Profit / Capital * 100',Default)

			/*==================================================================================*/
			/*RATIOID = 10 */
			/*
			THIS BLOCK IS FOR INSERTING DETAILS PERTAINING TO OPERATING COST RATIO
			*/
			SET @RATIONAME 	= dbo.LookupDictionaryItem('RETURN ON WORKING CAPITAL',Default) 
			SET @RATIOID	= 10
			SET @NETLOSS 	= 0
			SET @NETPROFIT 	= 0
			SELECT @NETLOSS 	= ISNULL(AMOUNT,0) FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Loss')
			SELECT @NETPROFIT 	= ISNULL(AMOUNT,0) FROM #TEMPTRADINGDETAILS WHERE LTRIM(RTRIM(ACCOUNTNAME)) IN (N'Net Profit')

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTASSETS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			SET @WORKINGCAPITAL = @BALANCE

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @LOANSADVANCES , @FROMDATE , @TODATE , @BALANCE OUTPUT
			SET @WORKINGCAPITAL = @WORKINGCAPITAL + @BALANCE

			SET @BALANCE = 0
			EXEC SP_ACC_RPT_RATIOSRECURSIVEBALANCE @CURRENTLIABILITIES_PROVISIONS , @FROMDATE , @TODATE , @BALANCE OUTPUT
			IF @BALANCE < 0
				SET @WORKINGCAPITAL = @WORKINGCAPITAL + @BALANCE
			ELSE
				SET @WORKINGCAPITAL = @WORKINGCAPITAL - @BALANCE

			IF @NETPROFIT > 0 AND @WORKINGCAPITAL > 0 
				BEGIN
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('NET PROFIT',Default),'0',@NETPROFIT,
						   dbo.LookupDictionaryItem('WORKING CAPITAL',Default),'0',@WORKINGCAPITAL ,dbo.LookupDictionaryItem('Net Profit / Working Capital * 100',Default)
				END  
			ELSE
				BEGIN
					INSERT INTO #RATIOS
					SELECT @RATIONAME AS 'Ratio Name',@RATIOID,dbo.LookupDictionaryItem('NET LOSS',Default),'0',0,
						   dbo.LookupDictionaryItem('WORKING CAPITAL',Default),'0',@WORKINGCAPITAL ,dbo.LookupDictionaryItem('Net Profit / Working Capital * 100',Default)
				END
			DROP TABLE #TEMPTRADINGDETAILS 
		END
