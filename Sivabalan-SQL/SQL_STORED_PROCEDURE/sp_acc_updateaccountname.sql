CREATE procedure sp_acc_updateaccountname
(
	@ACCOUNTID	int	, 	--THIS FIELD HAS THE VALUE OF ACCOUNT ID FOR WHICH THE NEW NAME IS TO BE UPDATED
	@NEWNAME	nVARCHAR(255)	--THIS FIELD HAS THE NEW ACCOUNTNAME WHICH IS TO BE UPDATED.
)
as
/*	PROCEDURE USED TO UPDATE THE ACCOUNT NAMES BASIS THE ACCOUNTID 
	UPDATE HAS TO BE MADE ONLY FOR NON FIXED ASSETS
*/

UPDATE 
	ACCOUNTSMASTER
SET 
	ACCOUNTNAME = @NEWNAME
WHERE
	ACCOUNTID = @ACCOUNTID
	AND
	ISNULL(FIXED,0)=0




