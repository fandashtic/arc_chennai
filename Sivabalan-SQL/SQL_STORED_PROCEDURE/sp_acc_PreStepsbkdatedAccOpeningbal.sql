CREATE Procedure [dbo].[sp_acc_PreStepsbkdatedAccOpeningbal]
/* Preliminary Procedure for update daily opening balance */
As

Create Table #TempDate (DateList DateTime)

Insert into #TempDate Select Distinct OpeningDate from AccountOpeningBalance
Group By OpeningDate,AccountID Having count(AccountID) > 1

Select * into #TempAccOpenBal from AccountOpeningBalance where OpeningDate in (Select DateList from #TempDate)

Delete from AccountOpeningBalance where OpeningDate in (Select DateList from #TempDate)

Insert Into AccountOpeningBalance (AccountID,OpeningDate,OpeningValue)
Select Distinct AccountID,OpeningDate,OpeningValue from #TempAccOpenBal

Drop Table #TempDate
Drop Table #TempAccOpenBal
