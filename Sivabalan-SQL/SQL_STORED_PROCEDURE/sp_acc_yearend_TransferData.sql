CREATE Procedure sp_acc_yearend_TransferData(@SourceDatabase nvarchar(50),@DestinationDatabase nvarchar(50),@YearEndDate datetime)
As
Set IMPLICIT_TRANSACTIONS OFF
/* Automatice journal entries for all fixed assets
Debit Depreciation A/C & Credit Asset A/C  */
Execute sp_acc_yearend_autoentrydepreciation @YearEndDate
/* Automatic journal entries to close to certain accounts */
Execute sp_acc_yearend_settingofaccounts @YearEndDate
/* copying some tables to new database and transfering current year closing balance
of all accounts to next years opening balance */
Execute sp_acc_yearend_DataCopy @SourceDatabase, @DestinationDatabase, @YearEndDate
Set IMPLICIT_TRANSACTIONS ON

